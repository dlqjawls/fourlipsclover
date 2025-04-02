package com.patriot.fourlipsclover.locals.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
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
	
	@Column(name = "region_name")
	private String regionName;
}
