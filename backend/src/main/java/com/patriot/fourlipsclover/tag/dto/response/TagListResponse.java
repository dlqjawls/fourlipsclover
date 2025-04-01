package com.patriot.fourlipsclover.tag.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TagListResponse {

    private long tagId;
    private String category;
    private String name;

}
