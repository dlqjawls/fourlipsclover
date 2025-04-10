package com.patriot.fourlipsclover.locals.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.patriot.fourlipsclover.locals.dto.request.LocalCertificationCreate;
import com.patriot.fourlipsclover.locals.dto.response.LocalCertificationResponse;
import com.patriot.fourlipsclover.locals.entity.LocalCertification;
import com.patriot.fourlipsclover.locals.entity.LocalGrade;
import com.patriot.fourlipsclover.locals.entity.LocalRegion;
import com.patriot.fourlipsclover.locals.mapper.LocalCertificationMapper;
import com.patriot.fourlipsclover.locals.repository.LocalCertificationRepository;
import com.patriot.fourlipsclover.locals.repository.LocalRegionRepository;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.restaurant.dto.request.LikeStatus;
import com.patriot.fourlipsclover.restaurant.repository.ReviewJpaRepository;
import com.patriot.fourlipsclover.restaurant.repository.ReviewLikeJpaRepository;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class LocalCertificationService {

	private final RestTemplate restTemplate;
	private final ObjectMapper objectMapper = new ObjectMapper();
	private final LocalCertificationRepository localCertificationRepository;
	private final LocalRegionRepository localRegionRepository;
	private final MemberRepository memberRepository;
	private final LocalCertificationMapper localCertificationMapper;
	private final ReviewJpaRepository reviewJpaRepository;
	private final ReviewLikeJpaRepository reviewLikeJpaRepository;
	@Value("${kakao.rest-api-key}")
	private String restApiKey;

	@Transactional
	public LocalCertificationResponse create(Long memberId, LocalCertificationCreate request) {
		Optional<LocalCertification> existLocalCertification = localCertificationRepository.findByMember_MemberId(
				memberId);
		if (existLocalCertification.isPresent()) {
			return localCertificationMapper.toDto(existLocalCertification.get());
		}
		String url =
				"https://dapi.kakao.com/v2/local/geo/coord2address.json?x=" + request.getLongitude()
						+ "&y=" + request.getLatitude() + "&input_coord=WGS84";

		HttpHeaders headers = new HttpHeaders();
		headers.set("Authorization", "KakaoAK " + restApiKey);

		HttpEntity<Void> entity = new HttpEntity<>(headers);

		ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity,
				String.class
		);
		String jsonResponse = response.getBody();

		try {
			JsonNode rootNode = objectMapper.readTree(jsonResponse);
			JsonNode documentsNode = rootNode.path("documents");

			if (documentsNode.isArray() && !documentsNode.isEmpty()) {
				JsonNode firstDocument = documentsNode.get(0);
				JsonNode roadAddressNode = firstDocument.path("address");

				if (!roadAddressNode.isMissingNode()) {
					String region2 = roadAddressNode.path("region_2depth_name").asText();
					LocalRegion localRegion = localRegionRepository.findByRegionName(
									region2)
							.orElseThrow(() -> new RuntimeException(
									"해당 지역 정보를 찾을 수 없습니다:" + region2));

					LocalCertification localCertification = LocalCertification.builder()
							.member(memberRepository.findById(memberId)
									.orElseThrow(() -> new RuntimeException(
											"회원 정보를 찾을 수 없습니다: " + memberId)))
							.localRegion(localRegion)
							.certificated(true)
							.certificatedAt(LocalDateTime.now())
							.expiryAt(LocalDateTime.now().plusMonths(1))
							.localGrade(LocalGrade.ONE)
							.build();

					LocalCertification savedCertification = localCertificationRepository.save(
							localCertification);
					return localCertificationMapper.toDto(savedCertification);
				} else {
					throw new RuntimeException("도로명 주소 정보를 찾을 수 없습니다.");
				}
			} else {
				throw new RuntimeException("주소 정보를 찾을 수 없습니다.");
			}
		} catch (JsonProcessingException e) {
			throw new RuntimeException("주소 정보 파싱 중 오류 발생", e);
		}
	}

	/**
	 * 회원의 현지인 등급을 업데이트합니다. 3개월마다 실행됩니다.
	 * <p>
	 * 등급 기준: - 새싹: 리뷰 1회, GPS 인증 - 두잎클로버: 리뷰 5회, 출석 - 세잎클로버: 리뷰 10회 이상 + 누적 좋아요 30회 - 네잎클로버: 리뷰 20회
	 * 이상 + 누적 좋아요 100회
	 */
	@Transactional
	public void updateLocalGrades() {
		// 인증된 모든 현지인 조회
		List<LocalCertification> certifications = localCertificationRepository.findByCertificatedTrue();

		for (LocalCertification certification : certifications) {
			Long memberId = certification.getMember().getMemberId();

			int reviewCount = getReviewCount(memberId);

			int totalLikes = getTotalLikes(memberId);

			LocalGrade newGrade;
			if (reviewCount >= 20 && totalLikes >= 100) {
				newGrade = LocalGrade.FOUR;
			} else if (reviewCount >= 10 && totalLikes >= 30) {
				newGrade = LocalGrade.THREE;
			} else if (reviewCount >= 5) {
				newGrade = LocalGrade.TWO;
			} else if (reviewCount >= 1) {
				newGrade = LocalGrade.ONE;
			} else {
				// 리뷰가 없으면 새싹 등급 유지
				newGrade = LocalGrade.ONE;
			}

			// 등급에 변화가 있을 때만 업데이트
			if (certification.getLocalGrade() != newGrade) {
				certification.updateGrade(newGrade);
				localCertificationRepository.save(certification);
			}
		}
	}

	/**
	 * 회원의 리뷰 수를 조회합니다.
	 */
	private int getReviewCount(Long memberId) {
		return reviewJpaRepository.countByMember_MemberId(memberId);
	}

	/**
	 * 회원이 받은 총 좋아요 수를 조회합니다.
	 */
	private int getTotalLikes(Long memberId) {
		return reviewLikeJpaRepository.countByMember_MemberIdAndLikeStatus(memberId,
				LikeStatus.LIKE);
	}
}
