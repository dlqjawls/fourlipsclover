package com.patriot.fourlipsclover.payment.repository;

import com.patriot.fourlipsclover.payment.entity.PaymentApproval;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;


@Repository
public interface PaymentApprovalRepository extends JpaRepository<PaymentApproval, Long> {

    List<PaymentApproval> findByPartnerUserId(String partnerUserId);

    Optional<Object> findByPartnerOrderId(String partnerOrderId);
    
}

