package com.patriot.fourlipsclover.notification.repository;

import com.patriot.fourlipsclover.notification.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    // 필요한 경우 추가 쿼리 메서드 정의
}
