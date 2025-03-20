package com.patriot.fourlipsclover.member.repository;

import com.patriot.fourlipsclover.member.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MemberRepository extends JpaRepository<Member, Integer> {

    Optional<Member> findByEmail(String email);

    Member findByMemberId(long l);

}
