package com.patriot.fourlipsclover.locals.controller;

import com.patriot.fourlipsclover.locals.dto.request.LocalCertificationCreate;
import com.patriot.fourlipsclover.locals.dto.response.LocalCertificationResponse;
import com.patriot.fourlipsclover.locals.service.LocalCertificationService;
import com.patriot.fourlipsclover.tag.service.TagService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/local-certification")
public class LocalCertificationController {

	private final LocalCertificationService localCertificationService;
	private final TagService tagService;

	@PostMapping("/{memberId}")
	@Operation(summary = "지역인증 생성", description = "회원의 위치 정보를 기반으로 지역인증을 생성합니다")
	public ResponseEntity<LocalCertificationResponse> create(
			@RequestBody LocalCertificationCreate request,
			@PathVariable(name = "memberId") Long memberId) {
		LocalCertificationResponse response = localCertificationService.create(memberId, request);
		return ResponseEntity.ok(response);
	}

	@PostMapping("/update")
	public void updateLocalGrades() {
		localCertificationService.updateLocalGrades();
		tagService.uploadAllLocalCertificationsToElasticsearch();
	}


}
