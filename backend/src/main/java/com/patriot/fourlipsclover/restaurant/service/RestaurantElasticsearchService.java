package com.patriot.fourlipsclover.restaurant.service;

import static co.elastic.clients.elasticsearch._types.query_dsl.TextQueryType.BestFields;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.ElasticsearchException;
import co.elastic.clients.elasticsearch._types.query_dsl.BoolQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.NestedQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.SearchRequest;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import com.patriot.fourlipsclover.restaurant.document.RestaurantDocument;
import com.patriot.fourlipsclover.restaurant.dto.request.RestaurantTagSearchRequest;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantSearchResponse;
import com.patriot.fourlipsclover.restaurant.mapper.RestaurantMapper;
import com.patriot.fourlipsclover.restaurant.mapper.RestaurantSearchMapper;
import com.patriot.fourlipsclover.tag.entity.Tag;
import com.patriot.fourlipsclover.tag.repository.TagRepository;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RestaurantElasticsearchService {

	private final ElasticsearchClient elasticsearchClient;
	private final RestaurantMapper restaurantMapper;
	private final RestaurantSearchMapper restaurantSearchMapper;
	private final TagRepository tagRepository;

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


	public List<RestaurantSearchResponse> searchByTagsAndQuery(RestaurantTagSearchRequest request) {
		try {
			BoolQuery.Builder boolQueryBuilder = new BoolQuery.Builder();

			if (request.getQuery() != null && !request.getQuery().isBlank()) {
				boolQueryBuilder.must(q -> q
						.multiMatch(mm -> mm
								.query(request.getQuery().trim())
								.fields(List.of("name^3", "address^2", "category"))
								.type(BestFields)
								.fuzziness("AUTO")
						)
				);
			}

			if (request.getTagIds() != null && !request.getTagIds().isEmpty()) {
				List<Tag> tags = tagRepository.findAllById(request.getTagIds());
				List<Query> tagQueries = new ArrayList<>();

				for (Tag tag : tags) {
					Query nestedQuery = NestedQuery.of(n -> n
							.path("tags")
							.query(q -> q
									.match(m -> m
											.field("tags.tagName")
											.query(tag.getName())
									)
							)
					)._toQuery();

					tagQueries.add(nestedQuery);
				}

				boolQueryBuilder.should(tagQueries);

				if (!tagQueries.isEmpty()) {
					boolQueryBuilder.minimumShouldMatch("1");
				}
			}

			SearchRequest searchRequest = SearchRequest.of(s -> s
					.index("restaurants")
					.query(q -> q.bool(boolQueryBuilder.build()))
					.size(20)
			);

			SearchResponse<RestaurantDocument> response =
					elasticsearchClient.search(searchRequest, RestaurantDocument.class);

			return response.hits().hits().stream()
					.map(Hit::source)
					.map(restaurantSearchMapper::toResponse)
					.collect(Collectors.toList());

		} catch (IOException e) {
			throw new RuntimeException("태그 및 검색어 기반 검색 중 오류가 발생했습니다.", e);
		}
	}
}
