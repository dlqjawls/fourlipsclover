package com.patriot.fourlipsclover.config;

import io.minio.MinioClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MinioReviewConfig {

	@Value("${minio.url}")
	private String minioUrl;

	@Value("${minio.accessKey}")
	private String accessKey;

	@Value("${minio.secretKey}")
	private String secretKey;

	@Value("${minio.bucketName}")
	private String bucketName;

	//버킷을 다 다르게 추가하려고하는데,, 흠,,
	@Bean
	public MinioClient minioClient() {
		return MinioClient.builder().endpoint(minioUrl).credentials(accessKey, secretKey).build();
	}

	@Bean
	public String getBucketName() {
		return this.bucketName;
	}
}
