package com.patriot.fourlipsclover.payment.repository;

import com.patriot.fourlipsclover.payment.entity.PaymentApproval;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface PaymentApprovalRepository extends JpaRepository<PaymentApproval, Long> {


	List<PaymentApproval> findByPartnerOrderId(String partnerOrderId);
}

