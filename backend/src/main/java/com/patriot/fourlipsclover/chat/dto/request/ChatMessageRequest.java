package com.patriot.fourlipsclover.chat.dto.request;

import com.patriot.fourlipsclover.chat.entity.MessageType;
import lombok.*;

@Data
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageRequest {

    private MessageType type;
    private Long senderId;
    private String messageContent;

}
