package com.patriot.fourlipsclover.group.repository;

import com.patriot.fourlipsclover.group.entity.Group;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GroupRepository extends JpaRepository<Group, Integer> {

    List<Group> findByMemberMemberId(Integer loggedInMemberId);

    void deleteById(Integer loggedInMemberId);

}
