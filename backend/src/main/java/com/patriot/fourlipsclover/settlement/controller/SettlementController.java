package com.patriot.fourlipsclover.settlement.controller;

import com.patriot.fourlipsclover.settlement.service.SettlementService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import java.net.URI;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/plans")
public class SettlementController {

	private final SettlementService settlementService;

	@PostMapping("/{planId}/settlement")
	@Operation(summary = "정산 생성", description = "특정 계획에 대한 정산을 생성합니다")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "201", description = "정산이 성공적으로 생성됨"),
			@ApiResponse(responseCode = "404", description = "계획을 찾을 수 없음")
	})
	public ResponseEntity<Void> create(
			@Parameter(description = "계획 ID", required = true)
			@PathVariable(value = "planId") Integer planId) {

		settlementService.create(planId);
		URI location = ServletUriComponentsBuilder
				.fromCurrentRequest()
				.build()
				.toUri();
		return ResponseEntity.created(location).build();
	}


}
