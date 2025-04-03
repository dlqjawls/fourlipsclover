package com.patriot.fourlipsclover.locals.controller;

import com.patriot.fourlipsclover.locals.document.LocalsDocument;
import com.patriot.fourlipsclover.locals.service.LocalsElasticsearchService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
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

	@Operation(summary = "현지인 추천", description = "현재 사용자와 비슷한 관심사를 가진 지역 현지인을 추천합니다")
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "추천 현지인 목록",
					content = @Content(mediaType = "application/json",
							array = @ArraySchema(schema = @Schema(implementation = LocalsDocument.class)))),
			@ApiResponse(responseCode = "404", description = "지역 정보를 찾을 수 없음"),
			@ApiResponse(responseCode = "500", description = "서버 오류")
	})
	@GetMapping("/{memberId}/find-locals/{regionId}")
	public ResponseEntity<List<LocalsDocument>> findLocals(
			@Parameter(description = "현재 사용자 ID") @PathVariable Long memberId,
			@Parameter(description = "검색할 지역 ID") @PathVariable(value = "regionId") Integer regionId) {
		return ResponseEntity.ok(
				localsElasticsearchService.recommendSimilarUsers(memberId, regionId));
	}

	@PostMapping("/upload-index")
	public void uploadIndex() {
		localsElasticsearchService.indexAllLocals();
	}

}
