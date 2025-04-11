package com.patriot.fourlipsclover.locals.repository;

import com.patriot.fourlipsclover.locals.document.LocalsDocument;
import java.util.Optional;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LocalsElasticsearchRepository extends
		ElasticsearchRepository<LocalsDocument, String> {

	Optional<LocalsDocument> findByMemberId(Long memberId);
}
