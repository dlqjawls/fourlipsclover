package com.patriot.fourlipsclover.tag.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class TagInfo {

	private String tag;
	private float score;
	private String category;
}
