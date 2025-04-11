package com.patriot.fourlipsclover.chat.repository;

import com.patriot.fourlipsclover.chat.entity.ChatMessage;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Integer> {

    List<ChatMessage> findByChatRoom_ChatRoomIdAndCreatedAtAfter(Integer chatRoomId, LocalDateTime after);

    List<ChatMessage> findByChatRoom_ChatRoomId(Integer chatRoomId);

    List<ChatMessage> findByChatRoom_ChatRoomIdOrderByCreatedAtAsc(Integer chatRoomId, PageRequest of);

    void deleteAllByChatRoom_ChatRoomId(Integer chatRoomId);
}
