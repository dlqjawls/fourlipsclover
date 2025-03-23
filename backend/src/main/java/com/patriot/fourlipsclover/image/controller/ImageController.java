package com.patriot.fourlipsclover.image.controller;

import com.patriot.fourlipsclover.image.service.ReviewImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/images")
@RequiredArgsConstructor
public class ImageController {

	private final ReviewImageService minioService;
//
//	@PostMapping("/upload")
//	public ResponseEntity<?> uploadImage(@RequestParam("file") MultipartFile file) {
//		try {
//			String objectName = minioService.uploadFiles(file);
//			return ResponseEntity.ok("Image uploaded successfully. Object name: " + objectName);
//		} catch (Exception e) {
//			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
//					.body("Error uploading image: " + e.getMessage());
//		}
//	}
}