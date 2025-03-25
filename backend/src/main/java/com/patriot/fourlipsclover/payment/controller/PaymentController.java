package com.patriot.fourlipsclover.payment.controller;

import com.patriot.fourlipsclover.payment.dto.response.PaymentApproveResponse;
import com.patriot.fourlipsclover.payment.dto.response.PaymentReadyResponse;
import com.patriot.fourlipsclover.payment.service.PaymentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/payment")
public class PaymentController {

	private final PaymentService paymentService;

	@PostMapping("/ready")
	@Operation(
			summary = "카카오페이 결제 준비",
			description = "사용자 정보와 상품 정보를 받아 카카오페이 결제를 준비하고 결제 URL을 반환합니다.",
			responses = {
					@ApiResponse(responseCode = "200", description = "결제 준비 성공",
							content = @Content(schema = @Schema(implementation = PaymentReadyResponse.class))),
					@ApiResponse(responseCode = "400", description = "잘못된 요청"),
					@ApiResponse(responseCode = "500", description = "서버 오류")
			}
	)
	public ResponseEntity<PaymentReadyResponse> ready(
			@Parameter(description = "사용자 ID", required = true) @RequestParam String userId,
			@Parameter(description = "상품명", required = true) @RequestParam String itemName,
			@Parameter(description = "상품 수량", required = true) @RequestParam String quantity,
			@Parameter(description = "결제 총액", required = true) @RequestParam String totalAmount) {

		PaymentReadyResponse response = paymentService.ready(userId, itemName, quantity,
				totalAmount);
		return ResponseEntity.ok(response);
	}

	@PostMapping("/approve")
	public ResponseEntity<PaymentApproveResponse> kakaoPayApprove(
			@RequestParam String tid,
			@RequestParam String pgToken,
			@RequestParam String orderId,
			@RequestParam String userId,
			@RequestParam int amount) {

		PaymentApproveResponse response = paymentService.approve(tid, pgToken, orderId, userId,
				amount);
		return ResponseEntity.ok(response);
	}
}
