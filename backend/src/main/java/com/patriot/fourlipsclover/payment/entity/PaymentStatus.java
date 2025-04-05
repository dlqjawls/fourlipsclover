package com.patriot.fourlipsclover.payment.entity;

public enum PaymentStatus {
	READY,        // 결제 준비 상태
	APPROVED,     // 결제 승인 완료
	CANCELED,     // 결제 취소됨
	FAILED,       // 결제 실패
	EXPIRED       // 결제 만료됨
}
