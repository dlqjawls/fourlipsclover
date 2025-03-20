package com.patriot.fourlipsclover.locals.controller;

import static org.assertj.core.api.Assertions.assertThat;

import com.patriot.fourlipsclover.locals.dto.request.LocalCertificationCreate;
import com.patriot.fourlipsclover.locals.dto.response.LocalCertificationResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.Sql.ExecutionPhase;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@Sql(scripts = {"/local-schema.sql",
		"/local-data.sql"}, executionPhase = ExecutionPhase.BEFORE_TEST_CLASS)
@Sql(scripts = {"/local-cleanup.sql"}, executionPhase = ExecutionPhase.AFTER_TEST_CLASS)
public class LocalCreateTest {

	@Autowired
	private TestRestTemplate restTemplate;

	@Test
	public void 로컬인증_생성_성공_강남구() {
		// given
		Long memberId = 1L;
		LocalCertificationCreate request = new LocalCertificationCreate();
		request.setLatitude(37.495352);
		request.setLongitude(127.044128);
		// request에 필요한 값 설정 (LocalCertificationCreate 클래스의 필드에 맞게 설정)
		// 예: request.setLocalRegionId("서울"); request.setLocalGrade("LEVEL1");

		// when
		ResponseEntity<LocalCertificationResponse> response = restTemplate.postForEntity(
				"/api/local-certification/{memberId}",
				request,
				LocalCertificationResponse.class,
				memberId
		);

		// then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(response.getBody().getLocalRegion().getRegionName()).isEqualTo("강남구");
		// 응답 내용 검증 (LocalCertificationResponse 클래스의 필드에 맞게 검증)
		// 예: assertThat(response.getBody().getLocalRegionId()).isEqualTo("서울");
	}

	@Test
	public void 로컬인증_생성_성공_광산구() {
		// given
		Long memberId = 1L;
		LocalCertificationCreate request = new LocalCertificationCreate();
		request.setLatitude(35.159787);
		request.setLongitude(126.807346);
		// request에 필요한 값 설정 (LocalCertificationCreate 클래스의 필드에 맞게 설정)
		// 예: request.setLocalRegionId("서울"); request.setLocalGrade("LEVEL1");

		// when
		ResponseEntity<LocalCertificationResponse> response = restTemplate.postForEntity(
				"/api/local-certification/{memberId}",
				request,
				LocalCertificationResponse.class,
				memberId
		);

		// then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(response.getBody().getLocalRegion().getRegionName()).isEqualTo("광산구");
		// 응답 내용 검증 (LocalCertificationResponse 클래스의 필드에 맞게 검증)
		// 예: assertThat(response.getBody().getLocalRegionId()).isEqualTo("서울");
	}
}
