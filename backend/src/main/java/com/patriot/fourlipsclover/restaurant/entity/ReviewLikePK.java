package com.patriot.fourlipsclover.restaurant.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

import java.util.Objects;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReviewLikePK {

    @Column(name = "review_id")
    private Integer reviewId;

    @Column(name = "member_id")
    private Long memberId;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        ReviewLikePK that = (ReviewLikePK) o;
        return Objects.equals(reviewId, that.reviewId) &&
                Objects.equals(memberId, that.memberId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(reviewId, memberId);
    }
}
