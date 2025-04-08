package com.patriot.fourlipsclover.restaurant.dto.request;

import jakarta.validation.constraints.NotNull;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class RestaurantTagSearchRequest {
	
	private List<Long> tagIds;
	@NotNull
	private String query;
}
