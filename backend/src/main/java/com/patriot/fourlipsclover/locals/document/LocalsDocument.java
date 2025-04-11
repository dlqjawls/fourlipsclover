package com.patriot.fourlipsclover.locals.document;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.Id;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;

@Document(indexName = "locals")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties(ignoreUnknown = true)
public class LocalsDocument {

	@Id
	private String id;

	@Field(type = FieldType.Long)
	private Long memberId;

	@Field(type = FieldType.Text, analyzer = "nori")
	private String nickname;

	@Field(type = FieldType.Keyword)
	private String regionName;

	@Field(type = FieldType.Keyword)
	private String localRegionId;

	@Field(type = FieldType.Keyword)
	private String localGrade;

	@Field(type = FieldType.Keyword)
	private String profileUrl;
	
	@Field(type = FieldType.Nested)
	private List<TagData> tags;

	@Data
	@NoArgsConstructor
	@AllArgsConstructor
	@Builder
	public static class TagData {

		@Field(type = FieldType.Text, analyzer = "nori")
		private String tagName;

		@Field(type = FieldType.Keyword)
		private String category;

		@Field(type = FieldType.Integer)
		private int frequency;

		@Field(type = FieldType.Float)
		private float avgConfidence;
	}
}

