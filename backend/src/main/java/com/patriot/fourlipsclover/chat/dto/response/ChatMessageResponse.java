package com.patriot.fourlipsclover.chat.dto.response;

import com.patriot.fourlipsclover.chat.entity.MessageType;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

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
    private List<String> imageUrls;  // 이미지 메시지의 경우 이미지 URL 목록
    private LocalDateTime createdAt;

}