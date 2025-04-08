package com.patriot.fourlipsclover.chat.repository;

import com.patriot.fourlipsclover.chat.entity.ChatRoom;
import com.patriot.fourlipsclover.match.entity.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Integer> {

    // 채팅방에 소속된 멤버로 채팅방을 찾는 쿼리
    @Query("SELECT cr FROM ChatRoom cr JOIN ChatMember cm ON cr.chatRoomId = cm.chatRoom.chatRoomId " +
            "WHERE cm.member.memberId = :memberId")
    List<ChatRoom> findByMemberId(@Param("memberId") Long memberId);

    // 매칭으로 채팅방을 찾는 쿼리
    Optional<ChatRoom> findByMatch(Match match);
}
