package com.patriot.fourlipsclover.match.entity;

import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "locals_proposal")
public class LocalsProposal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "proposal_id", nullable = false)
    private Integer proposalId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "match_id", nullable = false, unique = true)
    private Match match;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "proposal_restaurant",
            joinColumns = @JoinColumn(name = "proposal_id"),
            inverseJoinColumns = @JoinColumn(name = "restaurant_id")
    )
    private List<Restaurant> restaurantList;

    @Column(name = "recommend_menu", nullable = false)
    private String recommendMenu;

    @Column(name = "description")
    private String description;

}
