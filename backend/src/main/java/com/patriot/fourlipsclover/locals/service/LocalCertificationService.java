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
import java.time.LocalDateTime;
import java.util.Optional;
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
}
