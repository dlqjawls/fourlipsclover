package com.patriot.fourlipsclover.restaurant.controller;

import static org.assertj.core.api.Assertions.assertThat;

import com.patriot.fourlipsclover.restaurant.dto.request.LikeStatus;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewLikeCreate;
import com.patriot.fourlipsclover.restaurant.dto.response.ApiResponse;
import java.util.Collections;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.Sql.ExecutionPhase;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@Sql(scripts = {"/schema.sql", "/data.sql"}, executionPhase = ExecutionPhase.BEFORE_TEST_CLASS)
@Sql(scripts = {"/cleanup.sql"}, executionPhase = ExecutionPhase.AFTER_TEST_CLASS)
public class ReviewLikeCreateTest {

	@Autowired
	private TestRestTemplate restTemplate;

	@Test
	void 사용자는_다른사람의_리뷰에_좋아요를_달수있다() {
		//given
		ReviewLikeCreate request = new ReviewLikeCreate();
		request.setMemberId(2);
		request.setLikeStatus(LikeStatus.LIKE);
		//when

		//when
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
		ResponseEntity<ApiResponse<Void>> response = restTemplate.exchange(
				"/api/restaurant/reviews/1/like",
				HttpMethod.POST, new HttpEntity<>(request, headers),
				new org.springframework.core.ParameterizedTypeReference<ApiResponse<Void>>() {
				});

		//then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
	}
}
