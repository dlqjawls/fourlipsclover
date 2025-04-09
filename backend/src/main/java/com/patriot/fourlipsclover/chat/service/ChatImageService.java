package com.patriot.fourlipsclover.chat.service;

import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.errors.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatImageService {

    private final MinioClient minioClient;
    @Value("${minio.bucketName.chatImage}")
    private String bucketName;  // 채팅 메시지 이미지가 저장될 MinIO 버킷 이름

    // 이미지 업로드
    public String uploadImage(MultipartFile file) throws Exception {
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
            throw new RuntimeException("Image upload failed", e);
        }

        return objectName;  // 업로드된 이미지 URL 반환
    }

    // 다중 이미지 업로드
    public List<String> uploadImages(List<MultipartFile> images) throws Exception {
        return images.stream()
                .map(image -> {
                    try {
                        return uploadImage(image);  // 이미지 개별 업로드
                    } catch (Exception e) {
                        throw new RuntimeException("Failed to upload image", e);
                    }
                })
                .collect(Collectors.toList());
    }

    // 서명된 URL로 이미지 URL 반환 (이미지 다운로드용)
    public String getImageUrl(String imageName) throws Exception {
        String url = null;
        try {
            url = minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                            .bucket(bucketName)
                            .object(imageName)
                            .method(io.minio.http.Method.GET)
                            .expiry(1, TimeUnit.DAYS)  // URL 유효 기간 설정 (1일)
                            .build()
            );
        } catch (ErrorResponseException | InsufficientDataException | InternalException |
                 InvalidKeyException | InvalidResponseException | IOException |
                 NoSuchAlgorithmException | ServerException | XmlParserException e) {
            throw new RuntimeException("Error generating presigned URL", e);
        }

        // URL에서 쿼리 파라미터를 제외한 순수 URL 반환
        int queryIndex = url.indexOf('?');
        if (queryIndex > 0) {
            url = url.substring(0, queryIndex);
        }

        return url;
    }
}