package com.patriot.fourlipsclover.settlement.controller;

import com.patriot.fourlipsclover.settlement.dto.request.UpdateParticipantRequest;
import com.patriot.fourlipsclover.settlement.dto.response.UpdateParticipantResponse;
import com.patriot.fourlipsclover.settlement.service.ExpenseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/expenses")
@RequiredArgsConstructor
public class ExpenseController {

	private final ExpenseService expenseService;

	@PutMapping("/{expenseId}/participants")
	public ResponseEntity<UpdateParticipantResponse> updateParticipant(@PathVariable Long expenseId,
			@RequestBody UpdateParticipantRequest updateParticipantRequest
	) {
		UpdateParticipantResponse response = expenseService.updateParticipant(expenseId,
				updateParticipantRequest);
		return ResponseEntity.ok(response);
	}
}
