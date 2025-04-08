package com.patriot.fourlipsclover.chat.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChatMemberResponse {

    private Long memberId;
    private String memberNickname;
    private String profileUrl;
    private LocalDateTime joinedAt;

}