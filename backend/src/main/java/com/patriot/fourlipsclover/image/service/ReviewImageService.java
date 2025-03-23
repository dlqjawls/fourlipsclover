package com.patriot.fourlipsclover.image.service;

import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import java.io.InputStream;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class ReviewImageService {

	private final MinioClient minioClient;
	private final String bucketName;

	@Transactional
	public String uploadFile(MultipartFile file) throws Exception {
		String objectName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
		try (InputStream is = file.getInputStream()) {
			minioClient.putObject(
					PutObjectArgs.builder()
							.bucket(bucketName)
							.object(objectName)
							.stream(is, file.getSize(), -1)
							.contentType(file.getContentType())
							.build()
			);
		}
		return objectName;
	}
}
