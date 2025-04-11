package com.patriot.fourlipsclover.restaurant.dto.response;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantImageResponse {
    private Integer restaurantImageId;
    private Integer restaurantId;
    private String url;
}
