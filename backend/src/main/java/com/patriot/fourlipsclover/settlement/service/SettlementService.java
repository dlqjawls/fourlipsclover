package com.patriot.fourlipsclover.settlement.service;

import com.patriot.fourlipsclover.exception.PlanNotFoundException;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.payment.entity.PaymentApproval;
import com.patriot.fourlipsclover.payment.repository.PaymentApprovalRepository;
import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.repository.PlanRepository;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementResponse;
import com.patriot.fourlipsclover.settlement.entity.Settlement;
import com.patriot.fourlipsclover.settlement.entity.Settlement.SettlementStatus;
import com.patriot.fourlipsclover.settlement.exception.SettlementAlreadyExistsException;
import com.patriot.fourlipsclover.settlement.exception.SettlementNotFoundException;
import com.patriot.fourlipsclover.settlement.mapper.SettlementMapper;
import com.patriot.fourlipsclover.settlement.repository.SettlementRepository;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SettlementService {

	private final SettlementRepository settlementRepository;
	private final PlanRepository planRepository;
	private final SettlementMapper settlementMapper;
	private final PaymentApprovalRepository paymentApprovalRepository;

	@Transactional
	public void create(Integer planId) {
		if (!planRepository.existsById(planId)) {
			throw new PlanNotFoundException("존재하지 않는 계획입니다.");
		}
		if (settlementRepository.existsByPlan_PlanId(planId)) {
			throw new SettlementAlreadyExistsException(planId);
		}
		Settlement settlement = new Settlement();
		Plan plan = planRepository.findById(planId).orElseThrow();
		Member treasurer = plan.getGroup().getMember();
		settlement.setPlan(plan);
		settlement.setStartDate(plan.getStartDate().atStartOfDay());
		settlement.setEndDate(plan.getEndDate().atTime(LocalTime.MAX));
		settlement.setSettlementStatus(SettlementStatus.PENDING);
		settlement.setTreasurer(treasurer);

		settlementRepository.save(settlement);
	}

	@Transactional(readOnly = true)
	public SettlementResponse detail(Integer planId) {
		if (!planRepository.existsById(planId)) {
			throw new PlanNotFoundException("존재하지 않는 계획입니다.");
		}

		Settlement settlement = settlementRepository.findByPlan_PlanId(planId)
				.orElseThrow(() -> new SettlementNotFoundException(
						planId));
		LocalDateTime startAt = settlement.getPlan().getStartDate().atStartOfDay();
		LocalDateTime endAt = settlement.getPlan().getEndDate().atTime(LocalTime.MAX);
		List<PaymentApproval> paymentApprovals = paymentApprovalRepository.findByApprovedAtBetweenAndPartnerUserIdLike(
				startAt, endAt,
				String.valueOf(settlement.getTreasurer().getMemberId()));
		return settlementMapper.toDto(settlement, paymentApprovals);
	}
}
