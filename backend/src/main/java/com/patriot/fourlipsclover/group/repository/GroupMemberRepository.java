package com.patriot.fourlipsclover.group.repository;

import com.patriot.fourlipsclover.group.entity.GroupMember;
import com.patriot.fourlipsclover.group.entity.GroupMemberId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GroupMemberRepository extends JpaRepository<GroupMember, GroupMemberId> {

    void deleteByGroup_groupId(Integer groupId);

    List<GroupMember> findByGroup_GroupId(Integer groupId);

    GroupMember findByGroup_GroupIdAndMember_MemberId(Integer groupId, Long memberId);

    boolean existsByGroup_GroupIdAndMember_MemberId(Integer groupId, Long memberId);

    // Member ID로 Group 목록 조회
    List<GroupMember> findByIdMemberId(Long memberId);

    int countByMember_MemberId(long memberId);
}
