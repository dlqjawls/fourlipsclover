package com.patriot.fourlipsclover.restaurant.service;

import static co.elastic.clients.elasticsearch._types.query_dsl.TextQueryType.BestFields;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.ElasticsearchException;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import com.patriot.fourlipsclover.restaurant.document.RestaurantDocument;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantSearchResponse;
import com.patriot.fourlipsclover.restaurant.mapper.RestaurantMapper;
import com.patriot.fourlipsclover.restaurant.mapper.RestaurantSearchMapper;
import java.io.IOException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RestaurantElasticsearchService {

	private final ElasticsearchClient elasticsearchClient;
	private final RestaurantMapper restaurantMapper;
	private final RestaurantSearchMapper restaurantSearchMapper;

	public List<RestaurantResponse> searchRestaurants(String query) {
		try {
			SearchResponse<RestaurantDocument> response = elasticsearchClient.search(s -> s
							.index("restaurants")
							.size(20)
							.query(q -> q
									.multiMatch(mm -> mm
											.query(query)
											.fields(List.of("name^3", "address^2", "category", "tags"))
											.type(BestFields)
									)
							),
					RestaurantDocument.class
			);
			List<RestaurantDocument> restaurantDocuments = response.hits().hits().stream()
					.map(Hit::source)
					.toList();
			return restaurantMapper.documentToDto(restaurantDocuments);
		} catch (IOException e) {
			throw new RuntimeException("식당 검색 중 오류가 발생했습니다.", e);
		}
	}

	public List<RestaurantSearchResponse> searchRestaurantsByLocation(double lat, double lon,
			int distanceInMeters) {
		try {
			Query geoDistanceQuery = Query.of(q -> q
					.geoDistance(g -> g
							.field("location")           // RestaurantDocument의 location 필드
							.distance(distanceInMeters + "m") // 예: "5km"
							.location(loc -> loc.latlon(latlon -> latlon.lat(lat).lon(lon))))
			);
			SearchResponse<RestaurantDocument> searchResponse =
					elasticsearchClient.search(s -> s
									.index("restaurants")   // 실제 인덱스명 (예: "restaurant")
									.query(geoDistanceQuery)
									.size(20),            // 예: 최대 100건
							RestaurantDocument.class
					);

			return searchResponse.hits().hits().stream()
					.map(Hit::source)
					.map(restaurantSearchMapper::toResponse)
					.toList();
		} catch (ElasticsearchException e) {
			System.out.println(e.response().error());
		} catch (IOException e) {
			throw new RuntimeException("위치 기반 식당 검색 중 오류가 발생했습니다.", e);
		}
		return null;
	}
}
