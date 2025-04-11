package com.patriot.fourlipsclover.notification.service;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.notification.entity.Notification;
import com.patriot.fourlipsclover.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final MemberRepository memberRepository;

    /**
     * 그룹 가입 요청 알림 전송
     * 가입 요청이 발생하면, 그룹 리더(Member)를 대상으로 알림 엔티티를 생성하여 DB에 저장합니다.
     */
    public void sendGroupJoinRequestNotification(Integer groupId, Long groupLeaderId) {
        // 그룹 리더(Member) 엔티티를 조회합니다.
        Member groupLeader = memberRepository.findById(groupLeaderId)
                .orElseThrow(() -> new RuntimeException("그룹 리더 회원을 찾을 수 없습니다. id=" + groupLeaderId));

        String title = "그룹 가입 요청";
        String content = "회원 [" + "임시" + "] 님이 그룹 [" + groupId + "] 가입을 요청하였습니다.";

        Notification notification = new Notification();
        notification.setMember(groupLeader);
        notification.setTitle(title);
        notification.setContent(content);
        notification.setRead(false);
        notification.setCreatedAt(LocalDateTime.now());

        notificationRepository.save(notification);
    }
}