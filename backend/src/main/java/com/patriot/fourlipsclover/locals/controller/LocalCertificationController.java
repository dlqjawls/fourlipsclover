package com.patriot.fourlipsclover.locals.controller;

import com.patriot.fourlipsclover.locals.dto.request.LocalCertificationCreate;
import com.patriot.fourlipsclover.locals.dto.response.LocalCertificationResponse;
import com.patriot.fourlipsclover.locals.service.LocalCertificationService;
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

	@PostMapping("/{memberId}")
	public ResponseEntity<LocalCertificationResponse> create(
			@RequestBody LocalCertificationCreate request,
			@PathVariable(name = "memberId") Integer memberId) {
		LocalCertificationResponse response = localCertificationService.create(memberId, request);
		return ResponseEntity.ok(response);
	}
}
