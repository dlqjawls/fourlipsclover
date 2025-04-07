package com.patriot.fourlipsclover.mypage.dto.response;

import com.patriot.fourlipsclover.member.dto.response.MypagePlanResponse;
import com.patriot.fourlipsclover.tag.dto.response.RestaurantTagResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "마이페이지 응답 정보")
public class MypageResponse {

	@Schema(description = "회원 ID", example = "123456")
	private Long memberId;

	@Schema(description = "회원 이메일", example = "user@example.com")
	private String email;

	@Schema(description = "회원 닉네임", example = "맛있는사람")
	private String nickname;

	@Schema(description = "프로필 이미지 URL", example = "https://example.com/profile.jpg")
	private String profileUrl;

	@Schema(description = "회원 가입일", example = "2023-01-01T12:00:00")
	private LocalDateTime createdAt;

	@Schema(description = "신뢰도 점수", example = "4.5")
	private float trustScore;

	@Schema(description = "작성한 리뷰 수", example = "15")
	private int reviewCount;

	@Schema(description = "참여 그룹 수", example = "3")
	private int groupCount;

	@Schema(description = "최근 결제 내역 목록")
	private List<Payment> recentPayments;

	@Schema(description = "계획 응답 목록")
	private List<MypagePlanResponse> planResponses;

	@Schema(description = "로컬 인증 여부", example = "true")
	private boolean localAuth;

	@Schema(description = "현지인 등급", example = "골드")
	private String localRank;

	@Schema(description = "현지인 지역명", example = "서울시 강남구")
	private String localRegion;

	@Schema(description = "배지 이름", example = "맛집 탐험가")
	private String badgeName;

	@Schema(description = "관심 태그 목록")
	private List<RestaurantTagResponse> tags;

	@Data
	@NoArgsConstructor
	@AllArgsConstructor
	@Builder
	@Schema(description = "결제 정보")
	public static class Payment {

		@Schema(description = "상점명", example = "맛있는 식당")
		private String storeName;

		@Schema(description = "결제 금액", example = "25000")
		private int paymentAmount;
	}
}
