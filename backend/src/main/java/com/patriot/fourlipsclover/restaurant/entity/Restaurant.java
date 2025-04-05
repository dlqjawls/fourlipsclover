package com.patriot.fourlipsclover.restaurant.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Table(name = "restaurant")
public class Restaurant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "restaurant_id")
    private Integer restaurantId;

    @Column(name = "kakao_place_id")
    private String kakaoPlaceId;

    @Column(name = "place_name", length = 100)
    private String placeName;

    @Column(name = "address_name", length = 200)
    private String addressName;

    @Column(name = "road_address_name", length = 200)
    private String roadAddressName;

    @Column(length = 100)
    private String category;

    @Column
    private String categoryName;

    @Column(length = 20)
    private String phone;

    @Column(name = "place_url", length = 500)
    private String placeUrl;

    @Column(precision = 10)
    private Double x;

    @Column(precision = 10)
    private Double y;

    @ManyToOne
    @JoinColumn(name = "food_category_id")
    private FoodCategory foodCategory;

    @ManyToOne
    @JoinColumn(name = "city_id")
    private City city;

    @Column(name = "opening_hours")
    private String openingHours;

}
