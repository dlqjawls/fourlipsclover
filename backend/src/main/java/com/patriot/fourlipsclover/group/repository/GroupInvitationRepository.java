package com.patriot.fourlipsclover.group.repository;

import com.patriot.fourlipsclover.group.entity.GroupInvitation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface GroupInvitationRepository extends JpaRepository<GroupInvitation, Integer> {

    Optional<GroupInvitation> findByToken(String token);

}
