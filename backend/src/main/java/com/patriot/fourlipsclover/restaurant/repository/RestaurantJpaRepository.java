package com.patriot.fourlipsclover.restaurant.repository;

import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface RestaurantJpaRepository extends JpaRepository<Restaurant, Integer> {

	Optional<Restaurant> findByKakaoPlaceId(String kakaoPlaceId);

	@Query(value = "SELECT * FROM restaurant " +
			"WHERE (6371 * acos(cos(radians(:latitude)) * cos(radians(y)) * " +
			"cos(radians(x) - radians(:longitude)) + " +
			"sin(radians(:latitude)) * sin(radians(y)))) <= :radius/1000",
			nativeQuery = true)
	List<Restaurant> findNearbyRestaurants(
			@Param("latitude") Double latitude,
			@Param("longitude") Double longitude,
			@Param("radius") Integer radius);

	Restaurant findByRestaurantId(Integer restaurantId);

	boolean existsByRestaurantId(Integer restaurantId);

	// 랭킹 계산을 위한 데이터 조회 쿼리 (메인 카테고리 추가)
	@Query(value = """
        SELECT 
            r.restaurant_id AS restaurantId,
            r.place_name AS placeName,
            fc.name AS categoryName,
            c.name AS mainCategoryName,
            c.category_id AS mainCategoryId,
            COUNT(DISTINCT vp.visit_payment_id) AS visitCount,
            SUM(CASE 
                WHEN (rs.sentiment_status = 'POSITIVE' AND rl.like_status = 'LIKE') OR 
                     (rs.sentiment_status = 'NEGATIVE' AND rl.like_status = 'DISLIKE') 
                THEN m.trust_score ELSE 0 END) AS weightedPositive,
            SUM(CASE 
                WHEN (rs.sentiment_status = 'NEGATIVE' AND rl.like_status = 'LIKE') OR 
                     (rs.sentiment_status = 'POSITIVE' AND rl.like_status = 'DISLIKE') 
                THEN m.trust_score ELSE 0 END) AS weightedNegative,
            AVG(m.trust_score) AS avgUserTrustScore,
            COUNT(DISTINCT rev.review_id) AS reviewCount,
            AVG(vp.amount / vp.visited_personnel) AS avgPerPersonAmount
        FROM restaurant r
        LEFT JOIN food_category fc ON r.food_category_id = fc.food_category_id
        LEFT JOIN category c ON fc.category_id = c.category_id
        LEFT JOIN reviews rev ON r.restaurant_id = rev.restaurant_id AND rev.is_delete = 0
        LEFT JOIN review_sentiment rs ON rev.review_id = rs.review_id
        LEFT JOIN review_like rl ON rev.review_id = rl.review_id
        LEFT JOIN member m ON rev.member_id = m.member_id AND m.is_withdrawal = 0
        LEFT JOIN visit_payment vp ON r.restaurant_id = vp.restaurant_id
        GROUP BY r.restaurant_id, r.place_name, fc.name, c.name, c.category_id
        """, nativeQuery = true)
	List<Map<String, Object>> getRestaurantRankingData();

	// 메인 카테고리별 랭킹 데이터 조회 (새로 추가)
	@Query(value = """
        SELECT 
            r.restaurant_id AS restaurantId,
            r.place_name AS placeName,
            fc.name AS categoryName,
            c.name AS mainCategoryName,
            c.category_id AS mainCategoryId,
            COUNT(DISTINCT vp.visit_payment_id) AS visitCount,
            SUM(CASE 
                WHEN (rs.sentiment_status = 'POSITIVE' AND rl.like_status = 'LIKE') OR 
                     (rs.sentiment_status = 'NEGATIVE' AND rl.like_status = 'DISLIKE') 
                THEN m.trust_score ELSE 0 END) AS weightedPositive,
            SUM(CASE 
                WHEN (rs.sentiment_status = 'NEGATIVE' AND rl.like_status = 'LIKE') OR 
                     (rs.sentiment_status = 'POSITIVE' AND rl.like_status = 'DISLIKE') 
                THEN m.trust_score ELSE 0 END) AS weightedNegative,
            AVG(m.trust_score) AS avgUserTrustScore,
            COUNT(DISTINCT rev.review_id) AS reviewCount,
            AVG(vp.amount / vp.visited_personnel) AS avgPerPersonAmount
        FROM restaurant r
        LEFT JOIN food_category fc ON r.food_category_id = fc.food_category_id
        LEFT JOIN category c ON fc.category_id = c.category_id
        LEFT JOIN reviews rev ON r.restaurant_id = rev.restaurant_id AND rev.is_delete = 0
        LEFT JOIN review_sentiment rs ON rev.review_id = rs.review_id
        LEFT JOIN review_like rl ON rev.review_id = rl.review_id
        LEFT JOIN member m ON rev.member_id = m.member_id AND m.is_withdrawal = 0
        LEFT JOIN visit_payment vp ON r.restaurant_id = vp.restaurant_id
        WHERE c.category_id = :categoryId
        GROUP BY r.restaurant_id, r.place_name, fc.name, c.name, c.category_id
        """, nativeQuery = true)
	List<Map<String, Object>> getRestaurantRankingDataByMainCategory(@Param("categoryId") Integer categoryId);

	// 카테고리별 랭킹 데이터 조회 (메인 카테고리 추가)
	@Query(value = """
        SELECT 
            r.restaurant_id AS restaurantId,
            r.place_name AS placeName,
            fc.name AS categoryName,
            c.name AS mainCategoryName,
            c.category_id AS mainCategoryId,
            COUNT(DISTINCT vp.visit_payment_id) AS visitCount,
            SUM(CASE 
                WHEN (rs.sentiment_status = 'POSITIVE' AND rl.like_status = 'LIKE') OR 
                     (rs.sentiment_status = 'NEGATIVE' AND rl.like_status = 'DISLIKE') 
                THEN m.trust_score ELSE 0 END) AS weightedPositive,
            SUM(CASE 
                WHEN (rs.sentiment_status = 'NEGATIVE' AND rl.like_status = 'LIKE') OR 
                     (rs.sentiment_status = 'POSITIVE' AND rl.like_status = 'DISLIKE') 
                THEN m.trust_score ELSE 0 END) AS weightedNegative,
            AVG(m.trust_score) AS avgUserTrustScore,
            COUNT(DISTINCT rev.review_id) AS reviewCount,
            AVG(vp.amount / vp.visited_personnel) AS avgPerPersonAmount
        FROM restaurant r
        LEFT JOIN food_category fc ON r.food_category_id = fc.food_category_id
        LEFT JOIN category c ON fc.category_id = c.category_id
        LEFT JOIN reviews rev ON r.restaurant_id = rev.restaurant_id AND rev.is_delete = 0
        LEFT JOIN review_sentiment rs ON rev.review_id = rs.review_id
        LEFT JOIN review_like rl ON rev.review_id = rl.review_id
        LEFT JOIN member m ON rev.member_id = m.member_id AND m.is_withdrawal = 0
        LEFT JOIN visit_payment vp ON r.restaurant_id = vp.restaurant_id
        WHERE fc.name = :category
        GROUP BY r.restaurant_id, r.place_name, fc.name, c.name, c.category_id
        """, nativeQuery = true)
	List<Map<String, Object>> getRestaurantRankingDataByCategory(@Param("category") String category);

	// 특정 지역 내 랭킹 데이터 조회 (메인 카테고리 추가)
	@Query(value = """
        SELECT 
            r.restaurant_id AS restaurantId,
            r.place_name AS placeName,
            fc.name AS categoryName,
            c.name AS mainCategoryName,
            c.category_id AS mainCategoryId,
            COUNT(DISTINCT vp.visit_payment_id) AS visitCount,
            SUM(CASE 
                WHEN (rs.sentiment_status = 'POSITIVE' AND rl.like_status = 'LIKE') OR 
                     (rs.sentiment_status = 'NEGATIVE' AND rl.like_status = 'DISLIKE') 
                THEN m.trust_score ELSE 0 END) AS weightedPositive,
            SUM(CASE 
                WHEN (rs.sentiment_status = 'NEGATIVE' AND rl.like_status = 'LIKE') OR 
                     (rs.sentiment_status = 'POSITIVE' AND rl.like_status = 'DISLIKE') 
                THEN m.trust_score ELSE 0 END) AS weightedNegative,
            AVG(m.trust_score) AS avgUserTrustScore,
            COUNT(DISTINCT rev.review_id) AS reviewCount,
            AVG(vp.amount / vp.visited_personnel) AS avgPerPersonAmount
        FROM restaurant r
        LEFT JOIN food_category fc ON r.food_category_id = fc.food_category_id
        LEFT JOIN category c ON fc.category_id = c.category_id
        LEFT JOIN reviews rev ON r.restaurant_id = rev.restaurant_id AND rev.is_delete = 0
        LEFT JOIN review_sentiment rs ON rev.review_id = rs.review_id
        LEFT JOIN review_like rl ON rev.review_id = rl.review_id
        LEFT JOIN member m ON rev.member_id = m.member_id AND m.is_withdrawal = 0
        LEFT JOIN visit_payment vp ON r.restaurant_id = vp.restaurant_id
        WHERE (6371 * acos(cos(radians(:latitude)) * cos(radians(r.y)) * 
             cos(radians(r.x) - radians(:longitude)) + 
             sin(radians(:latitude)) * sin(radians(r.y)))) <= :radius/1000
        GROUP BY r.restaurant_id, r.place_name, fc.name, c.name, c.category_id
        """, nativeQuery = true)
	List<Map<String, Object>> getRestaurantRankingDataNearby(
			@Param("latitude") Double latitude,
			@Param("longitude") Double longitude,
			@Param("radius") Integer radius);
}