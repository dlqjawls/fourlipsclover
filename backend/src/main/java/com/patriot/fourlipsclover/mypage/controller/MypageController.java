package com.patriot.fourlipsclover.mypage.controller;

import com.patriot.fourlipsclover.member.service.MemberService;
import com.patriot.fourlipsclover.mypage.dto.response.MyPageProfileResponse;
import com.patriot.fourlipsclover.mypage.dto.response.MypageResponse;
import com.patriot.fourlipsclover.mypage.service.MypageImageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
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

	@Operation(
			summary = "마이페이지 정보 조회",
			description = "사용자의 마이페이지 정보를 조회합니다.",
			responses = {
					@ApiResponse(
							responseCode = "200",
							description = "마이페이지 정보 조회 성공",
							content = @Content(
									mediaType = "application/json",
									schema = @Schema(implementation = MypageResponse.class)
							)
					),
					@ApiResponse(
							responseCode = "404",
							description = "사용자 정보를 찾을 수 없음",
							content = @Content
					)
			}
	)
	@GetMapping("/{memberId}")
	public ResponseEntity<MypageResponse> getMypage(
			@Parameter(name = "memberId", description = "회원 ID", required = true, example = "23424111")
			@PathVariable Long memberId
	) {
		MypageResponse mypageData = memberService.getMypageData(memberId);
		return ResponseEntity.ok(mypageData);
	}
}
