package com.patriot.fourlipsclover.tag.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.patriot.fourlipsclover.member.entity.MemberReviewTag;
import com.patriot.fourlipsclover.restaurant.entity.RestaurantTag;
import com.patriot.fourlipsclover.restaurant.entity.Review;
import com.patriot.fourlipsclover.tag.dto.response.RestaurantTagResponse;
import com.patriot.fourlipsclover.tag.dto.response.TagInfo;
import com.patriot.fourlipsclover.tag.dto.response.TagListResponse;
import com.patriot.fourlipsclover.tag.dto.response.TagResponse;
import com.patriot.fourlipsclover.tag.entity.Tag;
import com.patriot.fourlipsclover.tag.repository.MemberReviewTagRepository;
import com.patriot.fourlipsclover.tag.repository.RestaurantTagRepository;
import com.patriot.fourlipsclover.tag.repository.TagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TagService {

    // 리뷰 컨텐츠 가져와서 태그 뽑기, restaurantTag, MemberTag 추가해주기.
    private final TagRepository tagRepository;
    private final MemberReviewTagRepository memberReviewTagRepository;
    private final RestaurantTagRepository restaurantTagRepository;
    private final WebClient webClient;
    @Value("${model.server.uri}")
    private String MODEL_SERVER_URI;

    public void generateTag(Review review) {
        Map<String, String> requestMap = new HashMap<>();
        requestMap.put("text", review.getContent());
        String requestBody = null;
        try {
            requestBody = new ObjectMapper().writeValueAsString(requestMap);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        TagResponse tagResponse = webClient.post().uri(MODEL_SERVER_URI + "/extract-tags")
                .contentType(
                        MediaType.APPLICATION_JSON).bodyValue(requestBody).retrieve()
                .bodyToMono(
                        TagResponse.class).block();
        for (TagInfo tagInfo : tagResponse.getTags()) {
            Tag tag = tagRepository.findByName(tagInfo.getTag());

            memberReviewTagRepository.findByMemberAndTag(
                            review.getMember().getMemberId(), tag.getName())
                    .ifPresentOrElse(existingTag -> {
                        existingTag.setFrequency(existingTag.getFrequency() + 1);
                        existingTag.setAvgConfidence(
                                (existingTag.getAvgConfidence() * (existingTag.getFrequency() - 1)
                                        + tagInfo.getScore()) / existingTag.getFrequency());
                        memberReviewTagRepository.save(existingTag);
                    }, () -> {
                        MemberReviewTag newTag = new MemberReviewTag();
                        newTag.setMember(review.getMember());
                        newTag.setTag(tag);
                        newTag.setFrequency(1);
                        newTag.setAvgConfidence(tagInfo.getScore());
                        memberReviewTagRepository.save(newTag);
                    });

            restaurantTagRepository.findByRestaurantKakaoPlaceIdAndTagName(
                            review.getRestaurant().getKakaoPlaceId(), tag.getName())
                    .ifPresentOrElse(existingTag -> {
                        existingTag.setFrequency(existingTag.getFrequency() + 1);
                        existingTag.setAvgConfidence(
                                (existingTag.getAvgConfidence() * (existingTag.getFrequency() - 1)
                                        + tagInfo.getScore()) / existingTag.getFrequency());
                        restaurantTagRepository.save(existingTag);
                    }, () -> {
                        RestaurantTag newTag = new RestaurantTag();
                        newTag.setFrequency(1);
                        newTag.setAvgConfidence(tagInfo.getScore());
                        newTag.setRestaurant(review.getRestaurant());
                        newTag.setTag(tag);
                        restaurantTagRepository.save(newTag);
                    });


        }

    }

    @Transactional(readOnly = true)
    public List<RestaurantTagResponse> findRestaurantTagByRestaurantId(String kakaoPlaceId) {
        List<RestaurantTag> restaurantTags = restaurantTagRepository.findRestaurantTagsByKakaoPlaceId(
                kakaoPlaceId);
        List<RestaurantTagResponse> response = new ArrayList<>();
        for (RestaurantTag data : restaurantTags) {
            RestaurantTagResponse responseDto = new RestaurantTagResponse();
            responseDto.setCategory(data.getTag().getCategory());
            responseDto.setTagName(data.getTag().getName());
            responseDto.setRestaurantTagId(data.getRestaurantTagId());
            response.add(responseDto);
        }
        return response;
    }

    @Transactional(readOnly = true)
    public List<RestaurantTagResponse> findRestaurantTagByMemberId(long memberId) {
        List<MemberReviewTag> memberTags = memberReviewTagRepository.findByMemberId(memberId);
        List<RestaurantTagResponse> tagList = new ArrayList<>();
        for (MemberReviewTag data : memberTags) {
            RestaurantTagResponse restaurantTagResponse = new RestaurantTagResponse();
            restaurantTagResponse.setRestaurantTagId(data.getMemberReviewTagId());
            restaurantTagResponse.setTagName(data.getTag().getName());
            restaurantTagResponse.setCategory(data.getTag().getCategory());
            tagList.add(restaurantTagResponse);
        }
        return tagList;
    }

    // 태그 전체 목록 조회
    public List<TagListResponse> getTagList() {
        List<Tag> tags = tagRepository.findAll();

        return tags.stream()
                .map(tag -> new TagListResponse(tag.getTagId(), tag.getCategory(), tag.getName()))
                .collect(Collectors.toList());
    }

}
