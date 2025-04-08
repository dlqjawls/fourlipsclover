package com.patriot.fourlipsclover.settlement.controller;

import com.patriot.fourlipsclover.settlement.dto.response.SettlementRequestResponse;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementResponse;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementSituationResponse;
import com.patriot.fourlipsclover.settlement.service.SettlementService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import java.net.URI;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
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

	@GetMapping("/{planId}/settlement")
	@Operation(summary = "정산 상세 조회", description = "특정 계획의 정산 정보를 상세 조회합니다")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "정산 정보 조회 성공"),
			@ApiResponse(responseCode = "404", description = "계획 또는 정산 정보를 찾을 수 없음")
	})
	public ResponseEntity<SettlementResponse> detail(
			@Parameter(description = "계획 ID", required = true)
			@PathVariable(value = "planId") Integer planId) {
		SettlementResponse response = settlementService.detail(planId);
		return ResponseEntity.ok(response);
	}

	@PostMapping("/{planId}/settlement/request")
	@Operation(summary = "정산 요청", description = "특정 계획에 대한 정산을 요청합니다")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "정산 요청 성공"),
			@ApiResponse(responseCode = "404", description = "계획 또는 정산 정보를 찾을 수 없음")
	})
	public ResponseEntity<SettlementRequestResponse> settlementRequest(
			@Parameter(description = "계획 ID", required = true)
			@PathVariable Integer planId) {
		SettlementRequestResponse response = settlementService.request(planId);
		return ResponseEntity.ok(response);
	}

	@GetMapping("/{planId}/settlement/situation")
	@Operation(summary = "정산 현황 조회", description = "특정 계획에 대한 정산 현황을 조회합니다")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "정산 현황 조회 성공"),
			@ApiResponse(responseCode = "404", description = "계획 또는 정산 정보를 찾을 수 없음")
	})
	public ResponseEntity<List<SettlementSituationResponse>> settlementSituation(
			@Parameter(description = "계획 ID", required = true)
			@PathVariable Integer planId) {
		List<SettlementSituationResponse> response = settlementService.settlementSituation(planId);
		return ResponseEntity.ok(response);
	}

	@PostMapping("/{planId}/settlement/transactions/{transactionId}/complete")
	@Operation(summary = "정산 거래 완료", description = "특정 정산 거래를 완료 처리합니다")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "정산 거래 완료 성공"),
			@ApiResponse(responseCode = "404", description = "거래 정보를 찾을 수 없음")
	})
	public ResponseEntity<String> completeTransaction(
			@Parameter(description = "계획 ID", required = true) @PathVariable Integer planId,
			@Parameter(description = "거래 ID", required = true) @PathVariable Long transactionId) {
		String response = settlementService.completeTransaction(planId, transactionId);
		return ResponseEntity.ok(response);
	}
}