package com.patriot.fourlipsclover.mypage.controller;

import com.patriot.fourlipsclover.member.service.MemberService;
import com.patriot.fourlipsclover.mypage.dto.response.MypageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "마이페이지", description = "마이페이지 관련 API")
public class MypageController {

	private final MemberService memberService;

	@Operation(summary = "마이페이지 더미 데이터 조회", description = "마이페이지에 표시될 더미 데이터를 제공합니다.")
	@GetMapping("/api/mypage/dummy")
	public Map<String, Object> getMypageDummy(
			@Parameter(name = "memberId", description = "회원 ID", required = true, example = "23424111")
			@RequestParam Long memberId
	) {
		Map<String, Object> response = new HashMap<>();
		MypageResponse mypageData = memberService.getMypageData(memberId);
		response.put("userId", mypageData.getMemberId());
		response.put("nickname", mypageData.getNickname());
		response.put("name", mypageData.getNickname());
		response.put("badgeName", "현지인");
		response.put("profileUrl", "http://fourlipsclover.duckdns.org:9000/mypage/download.jpeg");

		response.put("reviewCount", 10);
		response.put("groupCount", 2);
		response.put("albumCount", 5);

		List<Map<String, Object>> recentPayments = new ArrayList<>();
		Map<String, Object> payment1 = new HashMap<>();
		payment1.put("storeName", "장인족발");
		payment1.put("paymentAmount", 23000);
		payment1.put("menu", "족발");

		Map<String, Object> payment2 = new HashMap<>();
		payment2.put("storeName", "불난집");
		payment2.put("paymentAmount", 12000);
		payment2.put("menu", "갈비");

		Map<String, Object> payment3 = new HashMap<>();
		payment3.put("storeName", "솥뚜껑삼겹살");
		payment3.put("paymentAmount", 25000);
		payment3.put("menu", "삼겹살");

		recentPayments.add(payment1);
		recentPayments.add(payment2);
		recentPayments.add(payment3);
		response.put("recentPayments", recentPayments);

		response.put("luckGauge", 3);
		response.put("currentJourney", "광산구 맛집 투어");
		response.put("localAuth", true);

		return response;
	}
}
