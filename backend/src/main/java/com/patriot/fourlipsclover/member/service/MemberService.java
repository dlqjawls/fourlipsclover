package com.patriot.fourlipsclover.member.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.patriot.fourlipsclover.auth.dto.response.JwtResponse;
import com.patriot.fourlipsclover.auth.jwt.JwtTokenProvider;
import com.patriot.fourlipsclover.auth.service.KakaoAuthService;
import com.patriot.fourlipsclover.exception.UserInfoParsingException;
import com.patriot.fourlipsclover.group.repository.GroupMemberRepository;
import com.patriot.fourlipsclover.locals.entity.LocalCertification;
import com.patriot.fourlipsclover.locals.repository.LocalCertificationRepository;
import com.patriot.fourlipsclover.member.dto.response.MypagePlanResponse;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.mapper.MemberMapper;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.mypage.dto.response.MypageResponse;
import com.patriot.fourlipsclover.mypage.dto.response.MypageResponse.Payment;
import com.patriot.fourlipsclover.mypage.service.MypageImageService;
import com.patriot.fourlipsclover.payment.repository.PaymentApprovalRepository;
import com.patriot.fourlipsclover.plan.entity.PlanMember;
import com.patriot.fourlipsclover.plan.repository.PlanMemberRepository;
import com.patriot.fourlipsclover.restaurant.repository.ReviewJpaRepository;
import com.patriot.fourlipsclover.tag.dto.response.RestaurantTagResponse;
import com.patriot.fourlipsclover.tag.service.TagService;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MemberService {

	private final MemberRepository memberRepository;
	private final KakaoAuthService kakaoAuthService;
	private final JwtTokenProvider jwtTokenProvider;
	private final MemberMapper memberMapper;
	private final TagService tagService;
	private final ReviewJpaRepository reviewJpaRepository;
	private final GroupMemberRepository groupMemberRepository;
	private final PaymentApprovalRepository paymentApprovalRepository;
	private final LocalCertificationRepository localCertificationRepository;
	private final PlanMemberRepository planMemberRepository;
	private final MypageImageService mypageImageService;

	public JwtResponse processKakaoLoginAndGetToken(String accessToken) {
		String userInfo = kakaoAuthService.getUserInfo(accessToken);
		if (userInfo == null) {
			throw new UsernameNotFoundException("카카오 사용자 정보 조회 실패");
		}

		ObjectMapper objectMapper = new ObjectMapper();
		long kakaoId;
		String email;
		String nickname;
		String profileUrl;
		try {
			JsonNode rootNode = objectMapper.readTree(userInfo);

			JsonNode kakaoIdJsonNode = rootNode.path("id");
			kakaoId = kakaoIdJsonNode.asLong();

			JsonNode kakaoAccount = rootNode.path("kakao_account");
			email = kakaoAccount.path("email").asText();

			JsonNode profileNode = kakaoAccount.path("profile");
			nickname = profileNode.path("nickname").asText("새로운 사용자");
			profileUrl = profileNode.path("profile_image_url").asText("");
		} catch (Exception e) {
			throw new UserInfoParsingException("사용자 정보 파싱 실패", e);
		}

		Optional<Member> existingMember = memberRepository.findByEmail(email);
		Member member;
		if (existingMember.isPresent()) {
			member = existingMember.get();
		} else {
			member = new Member();
			member.setMemberId(kakaoId);
			member.setEmail(email);
			member.setNickname(nickname);
			member.setProfileUrl(profileUrl);
			member = memberRepository.save(member);
		}

		String jwtToken = jwtTokenProvider.generateToken(member);
		return new JwtResponse(jwtToken);
	}

	@Transactional(readOnly = true)
	public MypageResponse getMypageData(long memberId) {
		Member member = memberRepository.findByMemberId(memberId);
		String profileUrl = member.getProfileUrl();
		if (profileUrl != null && !profileUrl.isEmpty() && !StringUtils.startsWithAny(
				profileUrl.toLowerCase(), "http://", "https://")) {
			String url = mypageImageService.getProfileImageUrl(profileUrl);
			member.setProfileUrl(url);
		}
		MypageResponse response = memberMapper.toDto(member);
		List<RestaurantTagResponse> tagList = tagService.findRestaurantTagByMemberId(memberId);
		int reviewCount = reviewJpaRepository.countByMember_MemberId(memberId);
		response.setReviewCount(reviewCount);

		// 사용자가 속한 그룹 개수 불러오기
		int groupCount = groupMemberRepository.countByMember_MemberId(memberId);
		response.setGroupCount(groupCount);

		// 최근 3개 결제 내역 불러오기
		List<Payment> recentPayments = paymentApprovalRepository.findTop3ByPartnerUserIdOrderByApprovedAtDesc(
						String.valueOf(memberId))
				.stream()
				.map(payment -> MypageResponse.Payment.builder()
						.storeName(payment.getItemName())
						.paymentAmount(payment.getAmount().getTotal())
						.build())
				.toList();

		response.setRecentPayments(recentPayments);
		response.setTags(tagList);

		Optional<LocalCertification> localCertification = localCertificationRepository.findByMember_MemberId(
				memberId);
		localCertification.ifPresentOrElse(certification -> {
			response.setLocalAuth(certification.isCertificated()); // 인증 존재 여부 설정
			response.setLocalRank(certification.getLocalGrade().getValue());
			response.setLocalRegion(certification.getLocalRegion().getRegionName());
		}, () -> {
			response.setLocalAuth(false); // 인증 정보가 없는 경우 false로 설정
		});

		List<PlanMember> planMembers = planMemberRepository.findCurrentPlansByMember(member,
				LocalDate.now());
		List<MypagePlanResponse> mypagePlanResponses = new ArrayList<>();
		for (PlanMember planMember : planMembers) {
			MypagePlanResponse mypagePlanResponse = new MypagePlanResponse();
			mypagePlanResponse.setDescription(planMember.getPlan().getDescription());
			mypagePlanResponse.setEndDate(planMember.getPlan().getEndDate());
			mypagePlanResponse.setStartDate(planMember.getPlan().getStartDate());
			mypagePlanResponse.setPlanId(planMember.getPlan().getPlanId());
			mypagePlanResponse.setTitle(planMember.getPlan().getTitle());
			mypagePlanResponses.add(mypagePlanResponse);
		}
		response.setPlanResponses(mypagePlanResponses);
		response.setBadgeName("클로버");
		return response;
	}
}
