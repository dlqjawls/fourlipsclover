package com.patriot.fourlipsclover.image.service;

import com.patriot.fourlipsclover.restaurant.entity.Review;
import com.patriot.fourlipsclover.restaurant.entity.ReviewImage;
import com.patriot.fourlipsclover.restaurant.repository.ReviewImageRepository;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.errors.ErrorResponseException;
import io.minio.errors.InsufficientDataException;
import io.minio.errors.InternalException;
import io.minio.errors.InvalidResponseException;
import io.minio.errors.ServerException;
import io.minio.errors.XmlParserException;
import java.io.IOException;
import java.io.InputStream;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
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
	private final ReviewImageRepository reviewImageRepository;

	@Transactional
	public List<String> uploadFiles(Review review, List<MultipartFile> images) {
		List<String> imageUrls = new ArrayList<>();

		if (images == null || images.isEmpty()) {
			return imageUrls;
		}

		// 각 이미지 파일을 업로드하고 DB에 저장
		for (MultipartFile image : images) {
			try {
				String fileName = uploadImage(image);
				ReviewImage reviewImage = ReviewImage.builder()
						.review(review)
						.imageUrl(fileName)
						.createdAt(LocalDateTime.now())
						.build();
				reviewImageRepository.save(reviewImage);
				imageUrls.add(fileName);
			} catch (Exception e) {
				// 로깅 추가 또는 예외 처리 방식 결정 필요
				throw new RuntimeException("이미지 업로드 중 오류가 발생했습니다: " + e.getMessage(), e);
			}
		}
		return imageUrls;
	}

	private String uploadImage(MultipartFile file) {
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
		} catch (IOException | ErrorResponseException | InsufficientDataException |
				 InternalException | InvalidKeyException | InvalidResponseException |
				 NoSuchAlgorithmException | ServerException | XmlParserException e) {
			throw new RuntimeException(e);
		}
		return objectName;
	}

	public List<String> getImageUrlsByReviewId(Integer reviewId) {
		List<String> imageUrls = new ArrayList<>();
		List<ReviewImage> reviewImages = reviewImageRepository.findByReviewReviewId(reviewId);
		for (ReviewImage image : reviewImages) {
			imageUrls.add(image.getImageUrl());
		}
		return imageUrls;
	}
}
