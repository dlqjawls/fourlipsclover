package com.patriot.fourlipsclover.payment.entity;

import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "visit_payment")
public class VisitPayment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "visit_payment_id")
    private Integer visitPaymentId;

    @ManyToOne
    @JoinColumn(name = "restaurant_id")
    private Restaurant restaurantId;

    @Column(name = "user_id")
    private Integer userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "data_source")
    private DataSource dataSource;

    @Column(name = "visited_personnel")
    private Integer visitedPersonnel;

    @Column(name = "amount")
    private Integer amount;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

}
