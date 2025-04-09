package com.patriot.fourlipsclover.locals.repository;

import com.patriot.fourlipsclover.locals.dto.response.LocalCertificationResponse;
import com.patriot.fourlipsclover.locals.entity.LocalRegion;
import com.patriot.fourlipsclover.member.entity.Member;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LocalRegionRepository extends JpaRepository<LocalRegion, String> {

	Optional<LocalRegion> findByRegionNameContaining(
			String region2);

	Optional<LocalRegion> findByRegionName(String region2);

}
