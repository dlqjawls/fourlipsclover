package com.patriot.fourlipsclover.payment.service;

import com.patriot.fourlipsclover.payment.dto.response.PaymentApproveResponse;
import com.patriot.fourlipsclover.payment.dto.response.PaymentCancelResponse;
import com.patriot.fourlipsclover.payment.dto.response.PaymentReadyResponse;
import com.patriot.fourlipsclover.payment.mapper.PaymentMapper;
import com.patriot.fourlipsclover.payment.repository.PaymentApprovalRepository;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class PaymentService {

	private static final String KAKAO_PAY_READY_URL = "https://open-api.kakaopay.com/online/v1/payment/ready";
	private static final String KAKAO_PAY_APPROVE_URL = "https://open-api.kakaopay.com/online/v1/payment/approve";
	private static final String KAKAO_PAY_CANCEL = "https://open-api.kakaopay.com/online/v1/payment/cancel";
	private final PaymentApprovalRepository paymentApprovalRepository;
	private final PaymentMapper paymentMapper;
	private final String CID = "TC0ONETIME";
	@Value("${kakao.payment.admin-key}")
	private String ADMIN_KEY;

	public PaymentReadyResponse ready(String userId, String itemName,
			String quantity, String totalAmount) {
		RestTemplate restTemplate = new RestTemplate();
		String orderId = UUID.randomUUID().toString();
		HttpHeaders headers = new HttpHeaders();
		headers.set("Authorization", "SECRET_KEY " + ADMIN_KEY);
		headers.setContentType(MediaType.APPLICATION_JSON);

		Map<String, Object> params = new HashMap<>();
		params.put("cid", CID);
		params.put("partner_order_id", orderId);
		params.put("partner_user_id", userId);
		params.put("item_name", itemName);
		params.put("quantity", quantity);
		params.put("total_amount", totalAmount);
		params.put("tax_free_amount", 0);
		params.put("approval_url", "https://fourlipsclover.duckdns.org/api/payment/approve");
		params.put("cancel_url", "https://fourlipsclover.duckdns.org/api/payment/cancel");
		params.put("fail_url", "https://fourlipsclover.duckdns.org/api/payment/fail");

		HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(params, headers);
		ResponseEntity<PaymentReadyResponse> responseEntity = restTemplate.postForEntity(
				KAKAO_PAY_READY_URL, requestEntity, PaymentReadyResponse.class);
		PaymentReadyResponse response = responseEntity.getBody();
		response.setOrderId(orderId);
		System.out.println(response);

		return response;
	}

	public PaymentApproveResponse approve(String tid, String pgToken, String orderId, String userId,
			int amount) {
		RestTemplate restTemplate = new RestTemplate();

		HttpHeaders headers = new HttpHeaders();
		headers.set("Authorization", "SECRET_KEY " + ADMIN_KEY);
		headers.setContentType(MediaType.APPLICATION_JSON);

		Map<String, Object> params = new HashMap<>();
		params.put("cid", CID);
		params.put("tid", tid);
		params.put("partner_order_id", orderId);
		params.put("partner_user_id", userId);
		params.put("pg_token", pgToken);
		params.put("total_amount", String.valueOf(amount));

		HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(params, headers);
		ResponseEntity<PaymentApproveResponse> responseEntity = restTemplate.postForEntity(
				KAKAO_PAY_APPROVE_URL, requestEntity, PaymentApproveResponse.class);
		PaymentApproveResponse response = responseEntity.getBody();
		if (Objects.isNull(response)) {
			throw new IllegalArgumentException("존재하지 않는 거래입니다.");
		}
		paymentApprovalRepository.save(paymentMapper.toEntity(response));
		return responseEntity.getBody();
	}

	public PaymentCancelResponse cancel(String cid, String tid, Integer cancelAmount,
			Integer cancelTaxFreeAmount) {
		RestTemplate restTemplate = new RestTemplate();

		HttpHeaders headers = new HttpHeaders();
		headers.set("Authorization", "SECRET_KEY " + ADMIN_KEY);
		headers.setContentType(MediaType.APPLICATION_JSON);

		Map<String, Object> params = new HashMap<>();

		params.put("cid", cid);
		params.put("tid", tid);
		params.put("cancel_amount", cancelAmount);
		params.put("cancel_tax_free_amount", cancelTaxFreeAmount);

		HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(params, headers);
		ResponseEntity<PaymentCancelResponse> responseEntity = restTemplate.postForEntity(
				KAKAO_PAY_CANCEL, requestEntity, PaymentCancelResponse.class);

		return responseEntity.getBody();
	}
}
