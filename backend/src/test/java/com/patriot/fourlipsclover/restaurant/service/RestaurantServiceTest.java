package com.patriot.fourlipsclover.restaurant.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import java.time.LocalDateTime;
import java.util.Objects;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class RestaurantServiceTest {

	@Autowired
	private TestRestTemplate restTemplate;


	@Test
	void create_리뷰생성_API_테스트() throws Exception {
		// given - 리뷰 컨텐츠, 식당 정보,
		ReviewCreate request = new ReviewCreate();
		request.setContent("정말 맛있어요");
		request.setKakaoPlaceId("2114253032");
		request.setMemberId(1);
		request.setVisitedAt(LocalDateTime.now());
		// when
		ResponseEntity<ReviewResponse> response = restTemplate.exchange("/api/restaurant/reviews",
				HttpMethod.POST, new HttpEntity<>(request), ReviewResponse.class);
		// then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(Objects.requireNonNull(response.getBody()).getContent()).isEqualTo("정말 맛있어요");
	}


	@Test
	void findById() {
		//given
		//when
		ResponseEntity<ReviewResponse> response = restTemplate.exchange(
				"/api/restaurant/" + 1 + "/reviews", HttpMethod.GET, HttpEntity.EMPTY,
				ReviewResponse.class);
		//then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(Objects.requireNonNull(response.getBody()).getContent()).isEqualTo("테스트컨텐츠");
	}
}