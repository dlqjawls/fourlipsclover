package com.patriot.fourlipsclover.match.repository;

import com.patriot.fourlipsclover.match.entity.ApprovalStatus;
import com.patriot.fourlipsclover.match.entity.GuideRequestForm;
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

    List<Match> findByGuideRequestForm_Group_GroupId(int groupId); // groupId를 명시적으로 찾도록 수정

    void deleteByGuideRequestForm(GuideRequestForm guideRequestForm);
}
