package com.patriot.fourlipsclover.chat.entity;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class ChatMemberId implements Serializable {

    private Integer chatRoomId;
    private Long memberId;

}
