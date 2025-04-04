package com.patriot.fourlipsclover.tag.repository;

import com.patriot.fourlipsclover.tag.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TagRepository extends JpaRepository<Tag, Integer> {

    Tag findByName(String tag);
}
