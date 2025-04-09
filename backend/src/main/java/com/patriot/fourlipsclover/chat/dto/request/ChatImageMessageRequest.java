package com.patriot.fourlipsclover.chat.dto.request;

import com.patriot.fourlipsclover.chat.entity.MessageType;
import lombok.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Data
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatImageMessageRequest {

    private MessageType type;
    private Long senderId;
    private String messageContent;
    private List<MultipartFile> images;  // 다중 이미지를 처리

}
