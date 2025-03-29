package com.patriot.fourlipsclover.restaurant.entity;

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
@Table(name = "region")
public class Region {
    @Id
    @Column(name = "region_id")
    private int regionId;

    @Column(name = "name")
    private String name;

}
