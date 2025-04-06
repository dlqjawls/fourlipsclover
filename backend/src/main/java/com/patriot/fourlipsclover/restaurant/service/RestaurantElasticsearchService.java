package com.patriot.fourlipsclover.restaurant.service;

import static co.elastic.clients.elasticsearch._types.query_dsl.TextQueryType.BestFields;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import com.patriot.fourlipsclover.restaurant.document.RestaurantDocument;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.mapper.RestaurantMapper;
import java.io.IOException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RestaurantElasticsearchService {

	private final ElasticsearchClient elasticsearchClient;
	private final RestaurantMapper restaurantMapper;

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
}
