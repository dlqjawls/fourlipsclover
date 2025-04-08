package com.patriot.fourlipsclover.restaurant.service;

import static co.elastic.clients.elasticsearch._types.query_dsl.TextQueryType.BestFields;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.SortOrder;
import co.elastic.clients.elasticsearch._types.query_dsl.BoolQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.NestedQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch.core.SearchRequest;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import com.patriot.fourlipsclover.restaurant.document.RestaurantDocument;
import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.mapper.RestaurantSearchMapper;
import com.patriot.fourlipsclover.tag.entity.Tag;
import com.patriot.fourlipsclover.tag.repository.TagRepository;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RestaurantElasticsearchService {

	private final ElasticsearchClient elasticsearchClient;
	private final RestaurantSearchMapper restaurantSearchMapper;
	private final TagRepository tagRepository;

	public List<RestaurantResponse> searchRestaurantsByLocation(double lat, double lon,
			int distanceInMeters) {
		try {
			// 위치 기반 쿼리 생성
			Query geoDistanceQuery = Query.of(q -> q
					.geoDistance(g -> g
							.field("location")
							.distance(distanceInMeters + "m")
							.location(loc -> loc.latlon(latlon -> latlon.lat(lat).lon(lon))))
			);

			Query finalQuery = Query.of(q -> q
					.bool(b -> b
							.must(geoDistanceQuery)
							.mustNot(n -> n
									.wildcard(w -> w
											.field("category")
											.wildcard("*술집*")
									)
							)
							.mustNot(n -> n
									.wildcard(w -> w
											.field("category")
											.wildcard("*간식*")
									)
							)
					)
			);

			SearchResponse<RestaurantDocument> searchResponse =
					elasticsearchClient.search(s -> s
									.index("restaurants")
									.query(finalQuery)
									.sort(sort -> sort
											.geoDistance(gd -> gd
													.field("location")
													.location(loc -> loc.latlon(l -> l.lat(lat).lon(lon)))
													.order(SortOrder.Asc)
											)
									)
									.size(20),
							RestaurantDocument.class
					);
			return searchResponse.hits().hits().stream()
					.map(Hit::source)
					.map(restaurantSearchMapper::toResponse)
					.toList();
		} catch (IOException e) {
			throw new RuntimeException("위치 기반 식당 검색 중 오류가 발생했습니다.", e);
		}
	}


	public List<RestaurantResponse> searchByTagsAndQuery(String query, List<Long> tagIds) {
		try {
			BoolQuery.Builder boolQueryBuilder = new BoolQuery.Builder();
			if (query != null && !query.isBlank()) {
				boolQueryBuilder.must(q -> q
						.multiMatch(mm -> mm
								.query(query.trim())
								.fields(List.of("name^3", "address^2", "category"))
								.type(BestFields)
						)
				);
			}

			if (tagIds != null && !tagIds.isEmpty()) {
				List<Tag> tags = tagRepository.findAllById(tagIds);
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

				if (!tagQueries.isEmpty()) {
					boolQueryBuilder.should(tagQueries);
					// 태그 검색이 있는 경우, 최소 하나의 태그는 일치해야 함
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
					.toList();

		} catch (IOException e) {
			throw new RuntimeException("태그 및 검색어 기반 검색 중 오류가 발생했습니다.", e);
		}
	}

	public RestaurantResponse findRestaurantByKakaoPlaceId(String kakaoPlaceId) {
		try {
			SearchResponse<RestaurantDocument> response = elasticsearchClient.search(s -> s
							.index("restaurants")
							.query(q -> q
									.term(t -> t
											.field("kakaoPlaceId")
											.value(kakaoPlaceId)
									)
							),
					RestaurantDocument.class
			);

			if (Objects.requireNonNull(response.hits().total()).value() == 0) {
				throw new RuntimeException("해당 kakaoPlaceId에 일치하는 식당을 찾을 수 없습니다: " + kakaoPlaceId);
			}

			RestaurantDocument restaurantDocument = response.hits().hits().get(0).source();
			return restaurantSearchMapper.toResponse(restaurantDocument);
		} catch (IOException e) {
			throw new RuntimeException("kakaoPlaceId로 식당 검색 중 오류가 발생했습니다.", e);
		}
	}
}
