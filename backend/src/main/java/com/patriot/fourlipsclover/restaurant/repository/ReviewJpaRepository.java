package com.patriot.fourlipsclover.restaurant.repository;

import com.patriot.fourlipsclover.restaurant.entity.Review;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ReviewJpaRepository extends JpaRepository<Review, Integer> {

	@Query("select r from Review r where r.restaurant.kakaoPlaceId = :kakaoPlaceId and r.isDelete=false")
	List<Review> findByKakaoPlaceId(@Param("kakaoPlaceId") String kakaoPlaceId);


	int countByMember_MemberId(Long memberId);
}
