package com.patriot.fourlipsclover.chat.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChattingListResponse {

    private Integer chatRoomId;
    private String name;
    private int participantNum;

}
