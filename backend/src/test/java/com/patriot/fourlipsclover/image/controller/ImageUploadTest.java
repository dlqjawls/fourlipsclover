package com.patriot.fourlipsclover.image.controller;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
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
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.multipart.MultipartFile;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
public class ImageUploadTest {

	@Autowired
	private TestRestTemplate restTemplate;

	@Test
	void 사용자는_이미지를_업로드할수있다() throws IOException {
		//given
		// 테스트용 이미지 파일 경로
		String imagePath = "src/test/resources/test-image.png";
		File file = new File(imagePath);

		// MultipartFile 형식으로 변환
		MultipartFile multipartFile = new MockMultipartFile(
				"file", // 파라미터 이름
				"test-image.png", // 원본 파일명
				"image/png", // 콘텐츠 타입
				Files.readAllBytes(file.toPath()) // 파일 내용
		);

		// HTTP 요청 설정
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.MULTIPART_FORM_DATA);

		// MultiValueMap으로 파일 데이터 구성
		MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
		body.add("file", new ByteArrayResource(multipartFile.getBytes()) {
			@Override
			public String getFilename() {
				return multipartFile.getOriginalFilename();
			}
		});

		HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

		//when
		ResponseEntity<String> response = restTemplate.exchange(
				"/api/images/upload",
				HttpMethod.POST,
				requestEntity,
				String.class);

		//then
		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(response.getBody()).contains("Image uploaded successfully");
	}
}
