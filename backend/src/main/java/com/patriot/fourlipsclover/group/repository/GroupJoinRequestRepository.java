package com.patriot.fourlipsclover.group.repository;

import com.patriot.fourlipsclover.group.entity.GroupJoinRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GroupJoinRequestRepository extends JpaRepository<GroupJoinRequest, Long> {

    Optional<GroupJoinRequest> findByGroup_GroupIdAndMember_MemberIdAndToken(Integer groupId, Integer memberId, String token);

}
