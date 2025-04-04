package com.patriot.fourlipsclover.settlement.repository;


import com.patriot.fourlipsclover.settlement.entity.Expense;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ExpenseRepository extends JpaRepository<Expense, Long> {

}
