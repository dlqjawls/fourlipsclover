package com.patriot.fourlipsclover.restaurant.controller;

import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantRankingResponse;
import com.patriot.fourlipsclover.restaurant.service.RestaurantRankingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ranking")
@RequiredArgsConstructor
@Slf4j
public class RestaurantRankingController {

    private final RestaurantRankingService rankingService;

    @GetMapping
    public ResponseEntity<List<RestaurantRankingResponse>> getAllRankings() {
        List<RestaurantRankingResponse> rankings = rankingService.calculateRankings();
        return ResponseEntity.ok(rankings);
    }

    @GetMapping("/top/{categoryId}/{limit}")
    public ResponseEntity<List<RestaurantRankingResponse>> getTopRankingsByCategory(
            @PathVariable Integer categoryId,
            @PathVariable int limit) {

        // 메인 카테고리별 랭킹 조회
        List<RestaurantRankingResponse> categoryRankings = rankingService.calculateRankingsByMainCategory(categoryId);

        // 상위 n개 선택
        List<RestaurantRankingResponse> topRankings = categoryRankings.stream()
                .limit(limit)
                .toList();

        return ResponseEntity.ok(topRankings);
    }

    @GetMapping("/restaurant/{restaurantId}")
    public ResponseEntity<RestaurantRankingResponse> getRestaurantRanking(
            @PathVariable Integer restaurantId) {
        RestaurantRankingResponse ranking = rankingService.getRestaurantRanking(restaurantId);
        if (ranking != null) {
            return ResponseEntity.ok(ranking);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<List<RestaurantRankingResponse>> getRankingsByCategory(
            @PathVariable String category) {
        List<RestaurantRankingResponse> rankings = rankingService.calculateRankingsByCategory(category);
        return ResponseEntity.ok(rankings);
    }

    @GetMapping("/nearby")
    public ResponseEntity<List<RestaurantRankingResponse>> getNearbyRankings(
            @RequestParam Double latitude,
            @RequestParam Double longitude,
            @RequestParam(defaultValue = "1000") Integer radius) {
        List<RestaurantRankingResponse> rankings = rankingService.calculateRankingsNearby(
                latitude, longitude, radius);
        return ResponseEntity.ok(rankings);
    }

    @PostMapping("/retrain")
    public ResponseEntity<String> retrainModel() {
        try {
            rankingService.trainModel();
            return ResponseEntity.ok("랜덤 포레스트 모델 재학습이 완료되었습니다.");
        } catch (Exception e) {
            log.error("모델 재학습 실패", e);
            return ResponseEntity.internalServerError().body("모델 재학습 실패: " + e.getMessage());
        }
    }
}