package com.patriot.fourlipsclover.locals.repository;

import com.patriot.fourlipsclover.locals.dto.response.LocalCertificationResponse;
import com.patriot.fourlipsclover.locals.entity.LocalCertification;
import com.patriot.fourlipsclover.member.entity.Member;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LocalCertificationRepository extends JpaRepository<LocalCertification, Integer> {

	List<LocalCertification> findByCertificatedTrue();

	Optional<LocalCertification> findByMember_MemberId(Long memberId);

	Optional<LocalCertification> findByMember(Member reviewer);
}
