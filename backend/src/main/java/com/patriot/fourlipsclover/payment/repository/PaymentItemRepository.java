package com.patriot.fourlipsclover.payment.repository;

import com.patriot.fourlipsclover.payment.entity.PaymentItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaymentItemRepository extends JpaRepository<PaymentItem, Integer> {
    Optional<PaymentItem> findByPaymentItemId(Integer itemId);
}
