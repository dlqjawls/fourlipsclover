package com.patriot.fourlipsclover.group.repository;

import com.patriot.fourlipsclover.group.entity.GroupJoinRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GroupJoinRequestRepository extends JpaRepository<GroupJoinRequest, Integer> {

    Optional<GroupJoinRequest> findByGroup_GroupIdAndMember_MemberIdAndToken(Integer groupId, Long memberId, String token);

    List<GroupJoinRequest> findByGroup_GroupId(Integer groupId);

    void deleteByGroup_GroupId(int groupId);
}
