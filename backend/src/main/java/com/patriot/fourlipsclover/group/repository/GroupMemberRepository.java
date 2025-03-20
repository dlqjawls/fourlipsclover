package com.patriot.fourlipsclover.group.repository;

import com.patriot.fourlipsclover.group.entity.GroupMember;
import com.patriot.fourlipsclover.group.entity.GroupMemberId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GroupMemberRepository extends JpaRepository<GroupMember, Integer> {

    boolean existsById(GroupMemberId id);

    void deleteByGroup_groupId(int groupId);

    List<GroupMember> findByGroup_GroupId(Integer groupId);

    GroupMember findByGroup_GroupIdAndMember_MemberId(int groupId, Integer memberId);

    boolean existsByGroup_GroupIdAndMember_MemberId(Integer groupId, Integer memberId);
}
