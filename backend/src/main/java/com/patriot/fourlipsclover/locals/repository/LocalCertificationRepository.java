package com.patriot.fourlipsclover.locals.repository;

import com.patriot.fourlipsclover.locals.entity.LocalCertification;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LocalCertificationRepository extends JpaRepository<LocalCertification, Integer> {

	List<LocalCertification> findByCertificatedTrue();
}
