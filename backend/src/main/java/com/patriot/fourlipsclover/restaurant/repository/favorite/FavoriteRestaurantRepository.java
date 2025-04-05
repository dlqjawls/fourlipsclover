package com.patriot.fourlipsclover.restaurant.repository.favorite;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.restaurant.entity.favorite.FavoriteRestaurant;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FavoriteRestaurantRepository extends JpaRepository<FavoriteRestaurant, Integer> {

	List<FavoriteRestaurant> member(Member member);

	List<FavoriteRestaurant> findByMember_MemberId(Long memberId);
}
