package com.patriot.fourlipsclover.chat.dto.response;

import com.patriot.fourlipsclover.chat.entity.MessageType;
import lombok.*;

import java.time.LocalDateTime;

@Data
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageResponse {

    private Long messageId;
    private Integer chatRoomId;
    private Long memberId;
    private String nickname;
    private String profileUrl;
    private String messageContent;
    private MessageType messageType;
    private LocalDateTime createdAt;

    public ChatMessageResponse(Long messageId, Long memberId, String nickname, String messageContent, MessageType messageType, LocalDateTime createdAt) {
    }
}