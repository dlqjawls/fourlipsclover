package com.patriot.fourlipsclover.tag.dto.response;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TagResponse {

	private String text;
	private List<TagInfo> tags;
}
