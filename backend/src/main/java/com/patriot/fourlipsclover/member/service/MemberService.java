package com.patriot.fourlipsclover.member.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.patriot.fourlipsclover.auth.dto.response.JwtResponse;
import com.patriot.fourlipsclover.auth.jwt.JwtTokenProvider;
import com.patriot.fourlipsclover.auth.service.KakaoAuthService;
import com.patriot.fourlipsclover.exception.UserInfoParsingException;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.entity.MemberReviewTag;
import com.patriot.fourlipsclover.member.mapper.MemberMapper;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.mypage.dto.response.MypageResponse;
import com.patriot.fourlipsclover.mypage.service.MypageImageService;
import com.patriot.fourlipsclover.tag.dto.response.RestaurantTagResponse;
import com.patriot.fourlipsclover.tag.repository.MemberReviewTagRepository;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
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
	private final MypageImageService mypageImageService;
	private final MemberReviewTagRepository memberReviewTagRepository;

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
		MypageResponse response = memberMapper.toDto(member);
		List<MemberReviewTag> memberTags = memberReviewTagRepository.findByMemberId(memberId);
		List<RestaurantTagResponse> tagList = new ArrayList<>();
		for (MemberReviewTag data : memberTags) {
			RestaurantTagResponse restaurantTagResponse = new RestaurantTagResponse();
			restaurantTagResponse.setRestaurantTagId(data.getMemberReviewTagId());
			restaurantTagResponse.setTagName(data.getTag().getName());
			restaurantTagResponse.setCategory(data.getTag().getCategory());
			tagList.add(restaurantTagResponse);
		}
		response.setTags(tagList);
		return response;
	}
}
