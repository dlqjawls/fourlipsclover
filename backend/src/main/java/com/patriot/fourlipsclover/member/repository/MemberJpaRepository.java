package com.patriot.fourlipsclover.member.repository;

import com.patriot.fourlipsclover.member.entity.Member;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberJpaRepository extends JpaRepository<Member, Integer> {

	
	Optional<Member> findByEmail(String currentUsername);
}
