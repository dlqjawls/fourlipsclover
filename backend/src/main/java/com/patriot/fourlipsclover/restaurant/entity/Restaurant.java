package com.patriot.fourlipsclover.restaurant.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name = "restaurant")
public class Restaurant {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Integer id;

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
}
