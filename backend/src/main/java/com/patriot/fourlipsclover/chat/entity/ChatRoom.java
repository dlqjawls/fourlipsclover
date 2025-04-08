package com.patriot.fourlipsclover.chat.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.patriot.fourlipsclover.match.entity.Match;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "chat_room")
public class ChatRoom {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "chat_room_id", nullable = false)
    private Integer chatRoomId;

    @Column(name = "name", nullable = false, updatable = false)
    private String name;

    // 각 채팅방은 단 하나의 매칭과 연관됨 (matchId 별로 한 개)
    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "match_id", nullable = false, unique = true)
    @JsonIgnore
    private Match match;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

}
