package com.patriot.fourlipsclover.chat.dto.response;

import lombok.*;

import java.util.List;

@Data
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomResponse {

    private Integer chatRoomId;
    private String name;
    private List<ChatMessageResponse> messages;
    private List<ChatMemberResponse> members;
}