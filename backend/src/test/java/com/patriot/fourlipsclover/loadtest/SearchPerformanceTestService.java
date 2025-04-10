package com.patriot.fourlipsclover.loadtest;

import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.mapper.RestaurantSearchMapper;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantJpaRepository;
import com.patriot.fourlipsclover.restaurant.service.RestaurantElasticsearchService;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class SearchPerformanceTestService {

	private static final Logger log = LoggerFactory.getLogger(SearchPerformanceTestService.class);
	private final RestaurantJpaRepository restaurantRepository;
	private final RestaurantElasticsearchService elasticsearchService;
	private final RestaurantSearchMapper restaurantSearchMapper;

	public SearchPerformanceTestService(
			RestaurantJpaRepository restaurantRepository,
			RestaurantElasticsearchService elasticsearchService,
			RestaurantSearchMapper restaurantSearchMapper) {
		this.restaurantRepository = restaurantRepository;
		this.elasticsearchService = elasticsearchService;
		this.restaurantSearchMapper = restaurantSearchMapper;
	}

	public List<Restaurant> searchByJpa(double lat, double lon, int radius) {
		long startTime = System.currentTimeMillis();

		List<Restaurant> restaurants = restaurantRepository.findNearbyRestaurants(lat, lon, radius);

		long endTime = System.currentTimeMillis();
		log.info("JPA 검색 소요시간: {}ms, 결과 수: {}", (endTime - startTime), restaurants.size());

		return restaurants;
	}

	public List<RestaurantResponse> searchByElasticsearch(double lat, double lon, int radius) {
		long startTime = System.currentTimeMillis();

		List<RestaurantResponse> result = elasticsearchService.searchRestaurantsByLocation(lat, lon,
				radius);

		long endTime = System.currentTimeMillis();
		log.info("Elasticsearch 검색 소요시간: {}ms, 결과 수: {}", (endTime - startTime), result.size());

		return result;
	}
}