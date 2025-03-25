package com.patriot.fourlipsclover.payment.controller;

import com.patriot.fourlipsclover.payment.dto.response.PaymentApproveResponse;
import com.patriot.fourlipsclover.payment.dto.response.PaymentReadyResponse;
import com.patriot.fourlipsclover.payment.service.PaymentService;
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
	public ResponseEntity<PaymentReadyResponse> ready(
			@RequestParam String userId, @RequestParam String itemName,
			@RequestParam String quantity, @RequestParam String totalAmount) {

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
