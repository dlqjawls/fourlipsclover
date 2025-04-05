package com.patriot.fourlipsclover.restaurant.service;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.restaurant.dto.response.FavoriteRestaurantResponse;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.entity.favorite.FavoriteRestaurant;
import com.patriot.fourlipsclover.restaurant.mapper.FavoriteRestaurantMapper;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantJpaRepository;
import com.patriot.fourlipsclover.restaurant.repository.favorite.FavoriteRestaurantRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FavoriteRestaurantService {
	private final FavoriteRestaurantRepository favoriteRestaurantRepository;
	private final RestaurantJpaRepository restaurantJpaRepository;
	private final MemberRepository memberRepository;
	private final FavoriteRestaurantMapper favoriteRestaurantMapper;

	@Transactional
	public void create(Integer restaurantId, Long memberId) {
		FavoriteRestaurant favoriteRestaurant = new FavoriteRestaurant();
		Restaurant restaurant = restaurantJpaRepository.findByRestaurantId(restaurantId);
		Member member = memberRepository.findByMemberId(memberId);
		favoriteRestaurant.setMember(member);
		favoriteRestaurant.setRestaurant(restaurant);
		favoriteRestaurantRepository.save(favoriteRestaurant);
	}

	@Transactional(readOnly = true)
	public List<FavoriteRestaurantResponse> findByMemberId(Long memberId) {
		List<FavoriteRestaurant> favoriteRestaurants = favoriteRestaurantRepository.findByMember_MemberId(memberId);
		return favoriteRestaurantMapper.toDtoList(favoriteRestaurants);
	}
}
