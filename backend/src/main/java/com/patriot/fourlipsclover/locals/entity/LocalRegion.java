package com.patriot.fourlipsclover.locals.entity;

import com.patriot.fourlipsclover.restaurant.entity.Region;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "local_region")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class LocalRegion {

	@Id
	private String localRegionId;

	@ManyToOne
	@JoinColumn(name = "region_id")
	private Region region;

	@Column(name = "region_name")
	private String regionName;
}
