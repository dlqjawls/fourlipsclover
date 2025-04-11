package com.patriot.fourlipsclover.restaurant.controller;

import static org.assertj.core.api.Assertions.assertThat;

import com.patriot.fourlipsclover.restaurant.dto.request.LikeStatus;
import com.patriot.fourlipsclover.restaurant.dto.request.ReviewLikeCreate;
import com.patriot.fourlipsclover.restaurant.dto.response.ApiResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.core.ParameterizedTypeReference;
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
public class RestaurantReadTest {


	@Autowired
	private TestRestTemplate restTemplate;

	@Test
	void findById() {
		//given
		ReviewLikeCreate request = new ReviewLikeCreate();
		request.setMemberId(2L);
		request.setLikeStatus(LikeStatus.LIKE);
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));

		restTemplate.exchange(
				"/api/restaurant/reviews/1/like",
				HttpMethod.POST, new HttpEntity<>(request, headers),
				new org.springframework.core.ParameterizedTypeReference<ApiResponse<Void>>() {
				});
		//when
		ResponseEntity<ReviewResponse> response = restTemplate.exchange(
				"/api/restaurant/" + "2114253032" + "/reviews/1", HttpMethod.GET, HttpEntity.EMPTY,
				ReviewResponse.class);
		//then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(Objects.requireNonNull(response.getBody()).getContent()).isEqualTo("테스트컨텐츠");
		assertThat(Objects.requireNonNull(response.getBody()).getLikedCount()).isEqualTo(1);
		assertThat(Objects.requireNonNull(response.getBody()).getDislikedCount()).isEqualTo(0);
	}

	@Test
	void 사용자는_리뷰목록을_kakaoplaceid를_활용하여_제공받을_수_있다() {
		//given
		String kakaoId = "2114253032";
		//when
		ResponseEntity<List<ReviewResponse>> response = restTemplate.exchange(
				"/api/restaurant/" + kakaoId + "/reviews", HttpMethod.GET, HttpEntity.EMPTY,
				new ParameterizedTypeReference<List<ReviewResponse>>() {
				});
		//then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(response.getBody().get(0).getContent()).isEqualTo("테스트컨텐츠");
		assertThat(response.getBody().get(0).getRestaurant().getKakaoPlaceId()).isEqualTo(
				"2114253032");
	}

	@Test
	void 사용자는_kakaoPlaceId로_특정식당의상세정보를_불러올수있다() {
		//given
		String kakaoId = "2114253032";
		//when
		ResponseEntity<RestaurantResponse> response = restTemplate.exchange(
				"/api/restaurant/2114253032/search",
				HttpMethod.GET, HttpEntity.EMPTY, RestaurantResponse.class);
		//then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(response.getBody().getPlaceName()).isEqualTo("초돈");
	}

	@Test
	void 사용자는_GPS정보로_근처식당정보를_불러올수있다() {
		//given
		//when
		ResponseEntity<List<RestaurantResponse>> response = restTemplate.exchange(
				"/api/restaurant/nearby?latitude=126.830452421678&longitude=35.1912340501076&radius=1000",
				HttpMethod.GET, HttpEntity.EMPTY,
				new ParameterizedTypeReference<List<RestaurantResponse>>() {
				});
		//then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(response.getBody().size()).isEqualTo(1);
	}
}
