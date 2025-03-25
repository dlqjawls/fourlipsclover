package com.patriot.fourlipsclover.payment.service;

import com.patriot.fourlipsclover.payment.dto.response.PaymentApproveResponse;
import com.patriot.fourlipsclover.payment.dto.response.PaymentReadyResponse;
import com.patriot.fourlipsclover.payment.repository.PaymentRepository;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class PaymentService {

	private static final String KAKAO_PAY_READY_URL = "https://kapi.kakao.com/v1/payment/ready";
	private static final String KAKAO_PAY_APPROVE_URL = "https://kapi.kakao.com/v1/payment/approve";
	@Value("kakao.payment.adminKey")
	private final String ADMIN_KEY;
	private final PaymentRepository paymentRepository;
	private final String CID = "TC0ONETIME";

	public PaymentReadyResponse ready(String userId, String itemName,
			String quantity, String totalAmount) {
		RestTemplate restTemplate = new RestTemplate();
		String orderId = UUID.randomUUID().toString();
		HttpHeaders headers = new HttpHeaders();
		headers.set("Authorization", "KakaoAK " + ADMIN_KEY);
		headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

		MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
		params.add("cid", CID);
		params.add("partner_order_id", orderId);
		params.add("partner_user_id", userId);
		params.add("item_name", itemName);
		params.add("quantity", quantity);
		params.add("total_amount", totalAmount);
		// 실제 결제 완료 후 호출할 URL (도메인과 경로는 본인 환경에 맞게 설정)
		params.add("approval_url", "https://your-backend.com//api/payment/approve");
		params.add("cancel_url", "https://your-backend.com/api/payment/cancel");
		params.add("fail_url", "https://your-backend.com//api/payment/fail");

		HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(params, headers);
		ResponseEntity<PaymentReadyResponse> responseEntity = restTemplate.postForEntity(
				KAKAO_PAY_READY_URL, requestEntity, PaymentReadyResponse.class);
		PaymentReadyResponse response = responseEntity.getBody();
		
		response.setOrderId(orderId);
		return response;
	}

	public PaymentApproveResponse approve(String tid, String pgToken, String orderId, String userId,
			int amount) {
		RestTemplate restTemplate = new RestTemplate();

		HttpHeaders headers = new HttpHeaders();
		headers.set("Authorization", "KakaoAK " + ADMIN_KEY);
		headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

		MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
		params.add("cid", CID);
		params.add("tid", tid);
		params.add("partner_order_id", orderId);
		params.add("partner_user_id", userId);
		params.add("pg_token", pgToken);
		params.add("total_amount", String.valueOf(amount));

		HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(params, headers);
		ResponseEntity<PaymentApproveResponse> responseEntity = restTemplate.postForEntity(
				KAKAO_PAY_APPROVE_URL, requestEntity, PaymentApproveResponse.class);

		return responseEntity.getBody();
	}
}
