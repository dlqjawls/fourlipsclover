package com.patriot.fourlipsclover.payment.repository;

import com.patriot.fourlipsclover.payment.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
	
}
