package com.patriot.fourlipsclover.mypage.controller;

import com.patriot.fourlipsclover.member.service.MemberService;
import com.patriot.fourlipsclover.mypage.dto.response.MyPageProfileResponse;
import com.patriot.fourlipsclover.mypage.dto.response.MypageResponse;
import com.patriot.fourlipsclover.mypage.service.MypageImageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/mypage")
@Tag(name = "마이페이지", description = "마이페이지 관련 API")
public class MypageController {

	private final MemberService memberService;
	private final MypageImageService mypageImageService;

	@PostMapping(value = "/{memberId}/upload-profile-image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<MyPageProfileResponse> uploadProfileImage(@PathVariable Long memberId,
			@RequestPart(name = "image") MultipartFile image) {
		MyPageProfileResponse response = mypageImageService.uploadProfileImage(memberId, image);
		return ResponseEntity.ok(response);
	}

	@Operation(summary = "마이페이지 더미 데이터 조회", description = "마이페이지에 표시될 더미 데이터를 제공합니다.")
	@GetMapping("/dummy")
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
		response.put("profileUrl", mypageData.getProfileUrl());
		response.put("tags", mypageData.getTags());
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
