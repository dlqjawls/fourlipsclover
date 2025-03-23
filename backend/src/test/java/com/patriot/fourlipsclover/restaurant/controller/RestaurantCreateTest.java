package com.patriot.fourlipsclover.restaurant.controller;

import static org.assertj.core.api.Assertions.assertThat;

import com.patriot.fourlipsclover.restaurant.dto.request.ReviewCreate;
import com.patriot.fourlipsclover.restaurant.dto.response.ReviewResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Objects;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.Sql.ExecutionPhase;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@Sql(scripts = {"/schema.sql", "/data.sql"}, executionPhase = ExecutionPhase.BEFORE_TEST_CLASS)
@Sql(scripts = {"/cleanup.sql"}, executionPhase = ExecutionPhase.AFTER_TEST_CLASS)
public class RestaurantCreateTest {

	@Autowired
	private TestRestTemplate restTemplate;

	@Test
	void create_리뷰생성_이미지포함_API_테스트() throws Exception {
		// given - 리뷰 컨텐츠, 식당 정보, 이미지
		ReviewCreate request = new ReviewCreate();
		request.setContent("정말 맛있어요");
		request.setKakaoPlaceId("2114253032");
		request.setMemberId(1L);
		request.setVisitedAt(LocalDateTime.now());

		// 실제 이미지 파일 로드 (프로젝트 내 테스트 리소스 폴더에 이미지가 있어야 함)
		Path imagePath = Paths.get("src/test/resources/test-image.png");
		byte[] imageContent = Files.readAllBytes(imagePath);
		ByteArrayResource imageResource = new ByteArrayResource(imageContent) {
			@Override
			public String getFilename() {
				return "test-image.jpg"; // 파일명 지정
			}
		};

		// 멀티파트 요청 구성
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.MULTIPART_FORM_DATA);

		MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
		HttpEntity<ReviewCreate> requestEntity = new HttpEntity<>(request);
		body.add("data", requestEntity);
		body.add("images", imageResource);

		HttpEntity<MultiValueMap<String, Object>> requestBody = new HttpEntity<>(body, headers);

		// when
		ResponseEntity<ReviewResponse> response = restTemplate.exchange(
				"/api/restaurant/reviews",
				HttpMethod.POST,
				requestBody,
				ReviewResponse.class);

		// then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(Objects.requireNonNull(response.getBody()).getContent()).isEqualTo("정말 맛있어요");
		// 이미지가 저장되었는지 확인
		assertThat(Objects.requireNonNull(response.getBody()).getReviewImageUrls()).isNotEmpty();
	}

}
