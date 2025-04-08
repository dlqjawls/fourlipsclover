package com.patriot.fourlipsclover.chat.repository;

import com.patriot.fourlipsclover.chat.entity.ChatMember;
import com.patriot.fourlipsclover.chat.entity.ChatMemberId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatMemberRepository extends JpaRepository<ChatMember, ChatMemberId> {
    boolean existsByChatRoom_ChatRoomIdAndMember_MemberId(Integer chatRoomId, Long memberId);

    List<ChatMember> findByMember_MemberId(Long memberId);

    int countByChatRoom_ChatRoomId(Integer chatRoomId);

    List<ChatMember> findByChatRoom_ChatRoomId(Integer chatRoomId);
}
