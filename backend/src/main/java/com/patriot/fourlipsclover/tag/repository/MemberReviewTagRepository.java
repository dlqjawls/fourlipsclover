package com.patriot.fourlipsclover.tag.repository;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.entity.MemberReviewTag;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberReviewTagRepository extends JpaRepository<MemberReviewTag, Long> {

	@Query("select mrt from MemberReviewTag mrt where mrt.member.memberId =:memberId and mrt.tag.name =:tagName")
	Optional<MemberReviewTag> findByMemberAndTag(@Param("memberId") Long memberId,
			@Param("tagName") String tagName);

	@Query("select mrt from MemberReviewTag mrt where mrt.member.memberId =:memberId")
	List<MemberReviewTag> findByMemberId(@Param("memberId") long memberId);

	List<MemberReviewTag> findByMember(Member member);
}
