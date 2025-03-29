package com.patriot.fourlipsclover.match.repository;

import com.patriot.fourlipsclover.match.entity.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MatchRepository extends JpaRepository<Match, Integer> {
}
