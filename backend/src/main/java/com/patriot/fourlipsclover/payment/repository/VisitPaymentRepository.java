package com.patriot.fourlipsclover.payment.repository;

import com.patriot.fourlipsclover.payment.entity.VisitPayment;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VisitPaymentRepository extends JpaRepository<VisitPayment, Integer> {
    List<VisitPayment> findByRestaurantId_RestaurantId(Integer restaurantId);
}