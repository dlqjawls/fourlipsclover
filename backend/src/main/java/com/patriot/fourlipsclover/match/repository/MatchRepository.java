package com.patriot.fourlipsclover.match.repository;

import com.patriot.fourlipsclover.match.entity.ApprovalStatus;
import com.patriot.fourlipsclover.match.entity.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MatchRepository extends JpaRepository<Match, Integer> {
    List<Match> findByMemberId(long currentMemberId);

    List<Match> findByGuide_MemberId(Long guideId);

    List<Match> findByGuide_MemberIdAndStatus(long guideId, ApprovalStatus approvalStatus);

    Match findByMatchId(Integer matchId);
}
