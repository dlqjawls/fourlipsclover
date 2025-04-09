package com.patriot.fourlipsclover.chat.entity;

import com.patriot.fourlipsclover.member.entity.Member;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "chat_message")
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "message_id", nullable = false)
    private Long messageId;

    // 채팅 메시지는 특정 채팅방에 속합니다.
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "chat_room_id", nullable = false)
    private ChatRoom chatRoom;

    // 메시지를 보낸 사용자 정보
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "sender_id", nullable = false)
    private Member sender;

    // 메시지 내용 (일반 텍스트 또는 편집 업데이트 정보를 JSON 형식으로 저장할 수 있음)
    @Column(name = "message_content", nullable = false, columnDefinition = "TEXT")
    private String messageContent;

    // 메시지 유형: 예를 들어 TEXT, PLAN_UPDATE 등을 구분
    @Enumerated(EnumType.STRING)
    @Column(name = "message_type", nullable = false)
    private MessageType messageType;

    // 이미지 URL 목록
    @ElementCollection
    @CollectionTable(name = "chat_message_images", joinColumns = @JoinColumn(name = "message_id"))
    @Column(name = "image_url")
    private List<String> imageUrls;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
