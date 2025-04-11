package com.patriot.fourlipsclover.mypage.service;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.mypage.dto.response.MyPageProfileResponse;
import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.errors.ErrorResponseException;
import io.minio.errors.InsufficientDataException;
import io.minio.errors.InternalException;
import io.minio.errors.InvalidResponseException;
import io.minio.errors.ServerException;
import io.minio.errors.XmlParserException;
import io.minio.http.Method;
import java.io.IOException;
import java.io.InputStream;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@RequiredArgsConstructor
@Service
public class MypageImageService {

	private final MinioClient minioClient;
	private final MemberRepository memberRepository;
	@Value("${minio.bucketName.mypage}")
	private String bucketName;

	@Transactional
	public MyPageProfileResponse uploadProfileImage(Long memberId, MultipartFile file) {
		Member member = memberRepository.findByMemberId(memberId);
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
		member.setProfileUrl(objectName);
		return MyPageProfileResponse.builder().profileImageUrl(objectName).build();
	}

	@Transactional
	public String getProfileImageUrl(String imageName) {
		String url = null;
		try {
			url = minioClient.getPresignedObjectUrl(
					GetPresignedObjectUrlArgs.builder().bucket(bucketName).object(imageName).method(
							Method.GET).expiry(1, TimeUnit.DAYS).build());
		} catch (ServerException | InsufficientDataException | ErrorResponseException |
				 IOException | NoSuchAlgorithmException | InvalidKeyException |
				 InvalidResponseException | XmlParserException | InternalException e) {
			throw new RuntimeException(e);
		}
		int queryIndex = url.indexOf('?');
		if (queryIndex > 0) {
			url = url.substring(0, queryIndex);
		}
		return url;
	}

//	public List<String> getImageUrlsByReviewId(Integer reviewId) {
//		List<String> imageUrls = new ArrayList<>();
//		List<ReviewImage> reviewImages = reviewImageRepository.findByReviewReviewId(reviewId);
//		for (ReviewImage image : reviewImages) {
//			// MinioClient의 getUrl() 메서드 사용
//			String url = null;
//			try {
//				url = minioClient.getPresignedObjectUrl(
//						GetPresignedObjectUrlArgs.builder()
//								.bucket(bucketName)
//								.object(image.getImageUrl())
//								.method(Method.GET)
//								.expiry(7, TimeUnit.DAYS) // URL 유효기간 설정 (필요에 따라 조정)
//								.build()
//				);
//			} catch (ErrorResponseException | InsufficientDataException | InternalException |
//					 InvalidKeyException | InvalidResponseException | IOException |
//					 NoSuchAlgorithmException | XmlParserException | ServerException e) {
//				throw new RuntimeException(e);
//			}
//
//			// 서명된 URL에서 쿼리 파라미터 제거 (필요한 경우)
//			int queryIndex = url.indexOf('?');
//			if (queryIndex > 0) {
//				url = url.substring(0, queryIndex);
//			}
//
//			imageUrls.add(url);
//		}
//		return imageUrls;
//	}
}
