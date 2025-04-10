package com.patriot.fourlipsclover.locals.service;

import static co.elastic.clients.elasticsearch._types.query_dsl.ChildScoreMode.Sum;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.query_dsl.FunctionBoostMode;
import co.elastic.clients.elasticsearch._types.query_dsl.FunctionScoreMode;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.json.JsonData;
import com.patriot.fourlipsclover.group.entity.GroupMember;
import com.patriot.fourlipsclover.group.repository.GroupMemberRepository;
import com.patriot.fourlipsclover.locals.document.LocalsDocument;
import com.patriot.fourlipsclover.locals.entity.LocalCertification;
import com.patriot.fourlipsclover.locals.repository.LocalCertificationRepository;
import com.patriot.fourlipsclover.locals.repository.LocalsElasticsearchRepository;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.entity.MemberReviewTag;
import com.patriot.fourlipsclover.restaurant.document.RestaurantDocument;
import com.patriot.fourlipsclover.restaurant.repository.RegionRepository;
import com.patriot.fourlipsclover.tag.repository.MemberReviewTagRepository;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LocalsElasticsearchService {


	private final LocalCertificationRepository localCertificationRepository;
	private final MemberReviewTagRepository memberReviewTagRepository;
	private final LocalsElasticsearchRepository localsElasticsearchRepository;
	private final ElasticsearchClient elasticsearchClient;
	private final RegionRepository regionRepository;
	private final GroupMemberRepository groupMemberRepository;

	public List<LocalsDocument> recommendSimilarUsers(Long currentUserId, Integer regionId) {
		List<String> tags = memberReviewTagRepository.findByMemberId(
				currentUserId).stream().map(t -> t.getTag().getName()).toList();
		String regionName = regionRepository.findById(regionId).orElseThrow().getName();
		SearchResponse<LocalsDocument> response = null;
		try {
			response = elasticsearchClient.search(s -> s
							.index("locals")
							.query(q -> q.functionScore(fs -> {
								// 기본 쿼리: 현재 유저 제외 및 태그 매칭 (should 조건)
								fs.query(qb -> qb.bool(b -> {
									// 현재 유저 제외
									b.mustNot(mn -> mn.term(t -> t.field("memberId").value(currentUserId)));
									// 태그 리스트를 순회하며 각 태그에 대해 nested 쿼리 추가
									b.must(m -> m.term(
											t -> t.field("regionName").value(regionName)));
									for (String tag : tags) {
										b.should(sh -> sh.nested(n -> n
												.path("tags")
												.query(nq -> nq.match(m -> m
														.field("tags.tagName")
														.query(tag)))
												.scoreMode(
														Sum)
										));
									}
									if (!tags.isEmpty()) {
										b.minimumShouldMatch("1");
									}
									return b;
								}));

								// 동적으로 태그별 function_score 구성
								for (String tag : tags) {
									fs.functions(f -> f
											.filter(fq -> fq.nested(n -> n
													.path("tags")
													.query(nq -> nq.match(m -> m
															.field("tags.tagName")
															.query(tag)))
											))
											.scriptScore(ss -> ss.script(sc -> sc
													.source("double score = 0; " +
															"for (t in params._source.tags) { " +
															"  if(t.tagName == params.tag_name) { " +
															"    score += t.frequency * t.avgConfidence; " +
															"  } " +
															"} " +
															"return score;")
													.params("tag_name", JsonData.of(tag))
											))
									);
								}

								return fs.boostMode(FunctionBoostMode.Sum)
										.scoreMode(FunctionScoreMode.Sum);
							})),
					LocalsDocument.class
			);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}

		return response.hits().hits().stream()
				.map(Hit::source)
				.collect(Collectors.toList());
	}
	

	/**
	 * 그룹 ID를 기반으로 비슷한 식당을 추천합니다.
	 *
	 * @param groupId 그룹 ID
	 * @return 추천된 식당 목록
	 */
	public List<RestaurantDocument> recommendSimilarRestaurants(Integer groupId) {
		try {
			// 그룹의 태그 정보 조회
			List<Member> groupMembers = groupMemberRepository.findByGroup_GroupId(groupId).stream()
					.map(GroupMember::getMember).toList();
			List<String> groupTags = new ArrayList<>();
			for (Member mem : groupMembers) {
				List<String> memberTags = memberReviewTagRepository.findByMember(mem).stream()
						.map(t -> t.getTag().getName())
						.toList();
				groupTags.addAll(memberTags);
			}

			if (groupTags.isEmpty()) {
				return List.of();
			}

			SearchResponse<RestaurantDocument> response = elasticsearchClient.search(s -> s
							.index("restaurants")
							.query(q -> q.functionScore(fs -> {
								// 기본 쿼리: 태그 매칭 (should 조건)
								fs.query(qb -> qb.bool(b -> {
									// 태그 리스트를 순회하며 각 태그에 대해 nested 쿼리 추가
									for (String tag : groupTags) {
										b.should(sh -> sh.nested(n -> n
												.path("tags")
												.query(nq -> nq.match(m -> m
														.field("tags.tagName")
														.query(tag)))
												.scoreMode(Sum)
										));
									}
									b.minimumShouldMatch("1");
									return b;
								}));

								// 동적으로 태그별 function_score 구성
								for (String tag : groupTags) {
									fs.functions(f -> f
											.filter(fq -> fq.nested(n -> n
													.path("tags")
													.query(nq -> nq.match(m -> m
															.field("tags.tagName")
															.query(tag)))
											))
											.scriptScore(ss -> ss.script(sc -> sc
													.source("double score = 0; " +
															"for (t in params._source.tags) { " +
															"  if(t.tagName == params.tag_name) { " +
															"    score += t.frequency * t.avgConfidence; " +
															"  } " +
															"} " +
															"return score;")
													.params("tag_name", JsonData.of(tag))
											))
									);
								}

								return fs.boostMode(FunctionBoostMode.Sum)
										.scoreMode(FunctionScoreMode.Sum);
							}))
							.size(10),
					RestaurantDocument.class
			);

			return response.hits().hits().stream()
					.map(Hit::source)
					.collect(Collectors.toList());
		} catch (IOException e) {
			throw new RuntimeException("유사 식당 추천 중 오류가 발생했습니다.", e);
		}
	}

	/**
	 * 인증된 현지인 데이터를 Elasticsearch에 인덱싱합니다.
	 */
	public void indexAllLocals() {
		// 인증된 현지인 정보만 조회
		List<LocalCertification> localCertifications = localCertificationRepository.findByCertificatedTrue();

		for (LocalCertification cert : localCertifications) {
			// 회원 태그 정보 조회
			List<MemberReviewTag> memberReviewTags = memberReviewTagRepository.findByMember(
					cert.getMember());

			// 태그 데이터 변환
			List<LocalsDocument.TagData> tagDataList = memberReviewTags.stream()
					.map(tag -> LocalsDocument.TagData.builder()
							.tagName(tag.getTag().getName())
							.category(tag.getTag().getCategory())
							.frequency(tag.getFrequency())
							.avgConfidence(tag.getAvgConfidence())
							.build())
					.collect(Collectors.toList());

			// 지역명 정규화 (특별시, 광역시, 도 단위로)
			String regionName = cert.getLocalRegion().getRegion().getName();

			// LocalsDocument 생성
			LocalsDocument localsDocument = LocalsDocument.builder()
					.id(cert.getLocalCertificationId() + "")
					.memberId(cert.getMember().getMemberId())
					.nickname(cert.getMember().getNickname())
					.regionName(regionName)
					.localRegionId(cert.getLocalRegion().getLocalRegionId())
					.localGrade(cert.getLocalGrade().name())
					.tags(tagDataList)
					.profileUrl(cert.getMember().getProfileUrl())
					.build();

			// Elasticsearch에 저장
			localsElasticsearchRepository.save(localsDocument);
		}
	}
}