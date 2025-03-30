package com.patriot.fourlipsclover.tag.repository;

import com.patriot.fourlipsclover.restaurant.entity.RestaurantTag;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface RestaurantTagRepository extends JpaRepository<RestaurantTag, Long> {

	@Query("select rt from RestaurantTag rt where rt.tag.name =:name and rt.restaurant.kakaoPlaceId =:kakaoPlaceId")
	Optional<RestaurantTag> findByRestaurantKakaoPlaceIdAndTagName(
			@Param("kakaoPlaceId") String kakaoPlaceId,
			@Param("name") String name);
}
