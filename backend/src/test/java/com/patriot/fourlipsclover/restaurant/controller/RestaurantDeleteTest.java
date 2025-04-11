package com.patriot.fourlipsclover.restaurant.controller;

import static org.assertj.core.api.Assertions.assertThat;

import com.patriot.fourlipsclover.restaurant.dto.response.ReviewDeleteResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.Sql.ExecutionPhase;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@Sql(scripts = {"/schema.sql", "/data.sql"}, executionPhase = ExecutionPhase.BEFORE_TEST_CLASS)
@Sql(scripts = {"/cleanup.sql"}, executionPhase = ExecutionPhase.AFTER_TEST_CLASS)

public class RestaurantDeleteTest {

	@Autowired
	private TestRestTemplate restTemplate;

	@Test
	void reviewDelete() {
		//given
		int reviewId = 1;
		// when
		ResponseEntity<ReviewDeleteResponse> response = restTemplate.exchange(
				"/api/restaurant/reviews/" + reviewId, HttpMethod.DELETE, HttpEntity.EMPTY,
				ReviewDeleteResponse.class);
		// then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(response.getBody().getMessage()).isEqualTo("리뷰를 삭제하였습니다.");
		assertThat(response.getBody().getReviewId()).isEqualTo(reviewId);
	}
}
