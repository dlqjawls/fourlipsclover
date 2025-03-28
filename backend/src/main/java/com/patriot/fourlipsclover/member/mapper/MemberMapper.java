package com.patriot.fourlipsclover.member.mapper;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.mypage.dto.response.MypageResponse;
import org.springframework.stereotype.Component;

@Component
public class MemberMapper {

	public MypageResponse toDto(Member member) {
		return MypageResponse.builder()
				.memberId(member.getMemberId())
				.email(member.getEmail())
				.nickname(member.getNickname())
				.profileUrl(member.getProfileUrl())
				.createdAt(member.getCreatedAt())
				.trustScore(member.getTrustScore())
				.build();
	}
}
