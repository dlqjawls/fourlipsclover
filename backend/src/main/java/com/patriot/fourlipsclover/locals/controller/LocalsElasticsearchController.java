package com.patriot.fourlipsclover.locals.controller;

import com.patriot.fourlipsclover.locals.document.LocalsDocument;
import com.patriot.fourlipsclover.locals.service.LocalsElasticsearchService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/locals")
@RequiredArgsConstructor
public class LocalsElasticsearchController {

	private final LocalsElasticsearchService localsElasticsearchService;

	@GetMapping("/{memberId}/find-locals/{regionId}")
	public ResponseEntity<List<LocalsDocument>> findLocals(@PathVariable Long memberId,
			@PathVariable(value = "regionId") Integer regionId) {
		return ResponseEntity.ok(
				localsElasticsearchService.recommendSimilarUsers(memberId, regionId));
	}

	@PostMapping("/upload-index")
	public void uploadIndex() {
		localsElasticsearchService.indexAllLocals();
	}

}
