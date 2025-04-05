package com.patriot.fourlipsclover.settlement.service;

import com.patriot.fourlipsclover.exception.PlanNotFoundException;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.payment.entity.PaymentApproval;
import com.patriot.fourlipsclover.payment.repository.PaymentApprovalRepository;
import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.entity.PlanMember;
import com.patriot.fourlipsclover.plan.repository.PlanMemberRepository;
import com.patriot.fourlipsclover.plan.repository.PlanRepository;
import com.patriot.fourlipsclover.settlement.dto.response.ExpenseResponse;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementRequestResponse;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementResponse;
import com.patriot.fourlipsclover.settlement.dto.response.SettlementTransactionResponse;
import com.patriot.fourlipsclover.settlement.entity.Expense;
import com.patriot.fourlipsclover.settlement.entity.ExpenseParticipant;
import com.patriot.fourlipsclover.settlement.entity.Settlement;
import com.patriot.fourlipsclover.settlement.entity.Settlement.SettlementStatus;
import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction;
import com.patriot.fourlipsclover.settlement.entity.SettlementTransaction.TransactionStatus;
import com.patriot.fourlipsclover.settlement.exception.SettlementAlreadyExistsException;
import com.patriot.fourlipsclover.settlement.exception.SettlementNotFoundException;
import com.patriot.fourlipsclover.settlement.mapper.ExpenseMapper;
import com.patriot.fourlipsclover.settlement.mapper.SettlementMapper;
import com.patriot.fourlipsclover.settlement.mapper.SettlementTransactionMapper;
import com.patriot.fourlipsclover.settlement.repository.ExpenseParticipantRepository;
import com.patriot.fourlipsclover.settlement.repository.ExpenseRepository;
import com.patriot.fourlipsclover.settlement.repository.SettlementRepository;
import com.patriot.fourlipsclover.settlement.repository.SettlementTransactionRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
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
	private final PlanMemberRepository planMemberRepository;
	private final ExpenseParticipantRepository expenseParticipantRepository;
	private final ExpenseRepository expenseRepository;
	private final ExpenseMapper expenseMapper;
	private final SettlementTransactionRepository settlementTransactionRepository;
	private final SettlementTransactionMapper settlementTransactionMapper;

	@Transactional
	public void create(Integer planId) {
		if (settlementRepository.existsByPlan_PlanId(planId)) {
			throw new SettlementAlreadyExistsException(planId);
		}
		Settlement settlement = new Settlement();
		Plan plan = planRepository.findById(planId)
				.orElseThrow(() -> new PlanNotFoundException("존재하지 않는 계획입니다"));
		Member treasurer = plan.getGroup().getMember();
		settlement.setPlan(plan);
		settlement.setStartDate(plan.getStartDate().atStartOfDay());
		settlement.setEndDate(plan.getEndDate().atTime(LocalTime.MAX));
		settlement.setSettlementStatus(SettlementStatus.PENDING);
		settlement.setTreasurer(treasurer);
		LocalDateTime startAt = settlement.getPlan().getStartDate().atStartOfDay();
		LocalDateTime endAt = settlement.getPlan().getEndDate().atTime(LocalTime.MAX);
		settlementRepository.save(settlement);
		// 정산 참여자 결제 내역마다 모두 추가
		List<PaymentApproval> paymentApprovals = paymentApprovalRepository.findByApprovedAtBetweenAndPartnerUserIdLike(
				startAt, endAt,
				String.valueOf(settlement.getTreasurer().getMemberId()));
		List<PlanMember> planMembers = planMemberRepository.findByPlan_PlanId(planId);
		for (PaymentApproval paymentApproval : paymentApprovals) {
			Expense expense = new Expense();
			expense.setPaymentApproval(paymentApproval);
			expense.setSettlement(settlement);
			expenseRepository.save(expense);
			for (PlanMember planMember : planMembers) {
				ExpenseParticipant expenseParticipant = new ExpenseParticipant();
				expenseParticipant.setExpense(expense);
				expenseParticipant.setMember(planMember.getMember());
				expenseParticipantRepository.save(expenseParticipant);
			}
		}
	}

	@Transactional(readOnly = true)
	public SettlementResponse detail(Integer planId) {
		if (!planRepository.existsById(planId)) {
			throw new PlanNotFoundException("존재하지 않는 계획입니다.");
		}
		// settlement
		Settlement settlement = settlementRepository.findByPlan_PlanId(planId)
				.orElseThrow(() -> new SettlementNotFoundException(
						planId));
		List<ExpenseResponse> expenseResponses = new ArrayList<>();
		// expense
		List<Expense> expenses = expenseRepository.findBySettlement(settlement);
		for (Expense expense : expenses) {
			List<ExpenseParticipant> participants = expenseParticipantRepository.findByExpense(
					expense);
			ExpenseResponse expenseResponse = expenseMapper.toDto(expense, participants);
			expenseResponses.add(expenseResponse);
		}

		return settlementMapper.toDto(settlement, expenseResponses);
	}

	@Transactional
	public SettlementRequestResponse request(Integer planId) {
		Settlement settlement = settlementRepository.findByPlan_PlanId(planId)
				.orElseThrow(() -> new SettlementNotFoundException(planId));
		List<MemberCost> memberCosts = planMemberRepository.findByPlan_PlanId(planId).stream()
				.map(pm -> new MemberCost(pm.getMember())).toList();

		List<Expense> expenses = expenseRepository.findBySettlement(settlement);
		for (Expense expense : expenses) {
			List<ExpenseParticipant> expenseParticipants = expenseParticipantRepository.findByExpense(
					expense);
			Integer total = expense.getPaymentApproval().getAmount().getTotal();
			expenseParticipants.forEach(ep -> {
				for (MemberCost memberCost : memberCosts) {
					if (Objects.equals(ep.getMember().getMemberId(),
							memberCost.getMember().getMemberId())) {
						BigDecimal totalAmount = new BigDecimal(total);
						BigDecimal participantCount = new BigDecimal(expenseParticipants.size());
						BigDecimal share = totalAmount.divide(participantCount, 0,
								RoundingMode.CEILING);
						memberCost.increaseCost(share.intValue());
					}
				}
			});
		}
		List<SettlementTransaction> settlementTransactions = new ArrayList<>();
		for (MemberCost memberCost : memberCosts) {
			// 총무는 결제 트랜잭션에서 제외
			if (!Objects.equals(memberCost.getMember().getMemberId(),
					settlement.getTreasurer().getMemberId())) {
				SettlementTransaction settlementTransaction = new SettlementTransaction();
				settlementTransaction.setPayee(settlement.getTreasurer());
				settlementTransaction.setPayer(memberCost.getMember());
				settlementTransaction.setSettlement(settlement);
				settlementTransaction.setTransactionStatus(TransactionStatus.PENDING);
				settlementTransaction.setCost(memberCost.getCost());
				settlementTransactions.add(settlementTransaction);
			}
		}
		settlementTransactionRepository.saveAll(
				settlementTransactions);

		// 0이 아닌 멤버들만 결제 요청
		List<SettlementTransactionResponse> settlementTransactionResponses = settlementTransactions.stream()
				.filter(st ->
						st.getCost() != 0)
				.map(settlementTransactionMapper::toDto).toList();

		SettlementRequestResponse response = new SettlementRequestResponse();
		response.setPlanTitle(settlement.getPlan().getTitle());
		response.setRequestedDate(LocalDateTime.now());
		response.setSettlementId(settlement.getSettlementId());
		response.setSettlementTransactionResponses(settlementTransactionResponses);
		response.setTreasurer(
				settlementTransactionMapper.toTreasureResponse(settlement.getTreasurer()));

		return response;
	}

	private class MemberCost {

		private Member member;
		private Integer cost;

		public MemberCost(Member member) {
			this.member = member;
			this.cost = 0;
		}

		public Member getMember() {
			return member;
		}

		public Integer getCost() {
			return cost;
		}

		public void increaseCost(int moneyToAdd) {
			if (moneyToAdd > 0) {
				this.cost += moneyToAdd;
			}
		}
	}
}
