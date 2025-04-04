package com.patriot.fourlipsclover.settlement.service;

import com.patriot.fourlipsclover.exception.MemberNotFoundException;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.settlement.dto.request.UpdateParticipantRequest;
import com.patriot.fourlipsclover.settlement.dto.response.ExpenseParticipantResponse;
import com.patriot.fourlipsclover.settlement.dto.response.UpdateParticipantResponse;
import com.patriot.fourlipsclover.settlement.entity.Expense;
import com.patriot.fourlipsclover.settlement.entity.ExpenseParticipant;
import com.patriot.fourlipsclover.settlement.exception.AlreadyExistsExpenseParticipantException;
import com.patriot.fourlipsclover.settlement.exception.ExpenseNotFoundException;
import com.patriot.fourlipsclover.settlement.mapper.ExpenseMapper;
import com.patriot.fourlipsclover.settlement.repository.ExpenseParticipantRepository;
import com.patriot.fourlipsclover.settlement.repository.ExpenseRepository;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ExpenseService {

	private final ExpenseRepository expenseRepository;
	private final ExpenseParticipantRepository expenseParticipantRepository;
	private final MemberRepository memberRepository;
	private final ExpenseMapper expenseMapper;

	@Transactional
	public UpdateParticipantResponse updateParticipant(Long expenseId,
			UpdateParticipantRequest updateParticipantRequest) {
		Expense expense = expenseRepository.findById(expenseId)
				.orElseThrow(() -> new ExpenseNotFoundException(expenseId));
		expenseParticipantRepository.deleteAllByExpense_ExpenseId(expenseId);

		List<Long> memberIds = updateParticipantRequest.getMemberId();
		List<ExpenseParticipant> expenseParticipants = new ArrayList<>();
		for (Long memberId : memberIds) {
			if (expenseParticipantRepository.existsByExpense_ExpenseIdAndMember_MemberId(expenseId,
					memberId)) {
				throw new AlreadyExistsExpenseParticipantException(expenseId, memberId);
			}
			Member member = memberRepository.findById(memberId)
					.orElseThrow(() -> new MemberNotFoundException("존재하지 않는 Member 입니다."));
			ExpenseParticipant expenseParticipant = new ExpenseParticipant();
			expenseParticipant.setExpense(expense);
			expenseParticipant.setMember(member);
			expenseParticipants.add(expenseParticipant);
		}

		List<ExpenseParticipantResponse> participants = expenseMapper.toExpenseParticipantResponseList(
				expenseParticipantRepository.saveAll(expenseParticipants));
		return new UpdateParticipantResponse(expenseId, participants);
	}
}
