package com.patriot.fourlipsclover.tag.controller;

import com.patriot.fourlipsclover.tag.dto.response.TagListResponse;
import com.patriot.fourlipsclover.tag.service.TagService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/tag")
public class TagController {

    private final TagService tagService;

    // 태그 전체 목록 조회
    @GetMapping
    public ResponseEntity<List<TagListResponse>> getTagList() {
        List<TagListResponse> response = tagService.getTagList();
        return ResponseEntity.ok(response);
    }

}
