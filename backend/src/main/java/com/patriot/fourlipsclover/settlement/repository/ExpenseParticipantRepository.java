package com.patriot.fourlipsclover.settlement.repository;

import com.patriot.fourlipsclover.settlement.entity.Expense;
import com.patriot.fourlipsclover.settlement.entity.ExpenseParticipant;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ExpenseParticipantRepository extends
		JpaRepository<ExpenseParticipant, Long> {

	List<ExpenseParticipant> findByExpense(Expense expense);
}
