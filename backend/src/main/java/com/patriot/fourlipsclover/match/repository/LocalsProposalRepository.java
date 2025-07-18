package com.patriot.fourlipsclover.match.repository;

import com.patriot.fourlipsclover.match.entity.LocalsProposal;
import com.patriot.fourlipsclover.match.entity.Match;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LocalsProposalRepository extends JpaRepository<LocalsProposal, Integer> {

    Optional<LocalsProposal> findByMatch_MatchId(Integer matchId);

    Optional<Object> findByMatch(Match match);
}
