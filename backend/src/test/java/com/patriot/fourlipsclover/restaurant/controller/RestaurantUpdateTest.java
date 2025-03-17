package com.patriot.fourlipsclover.restaurant.controller;

import static org.assertj.core.api.Assertions.assertThat;

import com.patriot.fourlipsclover.restaurant.dto.request.ReviewUpdate;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import java.time.LocalDateTime;
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
public class RestaurantUpdateTest {

	@Autowired
	private TestRestTemplate restTemplate;

	@Test
	void 사용자는_자신이_작성한_리뷰의_content와visitedAt을_수정할수있다() {
		LocalDateTime currentTime = LocalDateTime.now();
		//given
		final int reviewId = 1;
		ReviewUpdate reviewUpdate = new ReviewUpdate();
		reviewUpdate.setContent("컨텐츠 변경");
		reviewUpdate.setVisitedAt(currentTime);
		//when
		ResponseEntity<ReviewResponse> response = restTemplate.exchange(
				"/api/restaurant/reviews/" + reviewId, HttpMethod.PUT,
				new HttpEntity<>(reviewUpdate), ReviewResponse.class);
		//then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(response.getBody().getContent()).isEqualTo("컨텐츠 변경");
	}
}
