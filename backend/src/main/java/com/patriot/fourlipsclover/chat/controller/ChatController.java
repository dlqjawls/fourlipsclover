package com.patriot.fourlipsclover.chat.controller;

import com.patriot.fourlipsclover.chat.dto.request.ChatMessageRequest;
import com.patriot.fourlipsclover.chat.dto.request.InviteMembersRequest;
import com.patriot.fourlipsclover.chat.dto.response.ChatMessageResponse;
import com.patriot.fourlipsclover.chat.dto.response.ChatRoomResponse;
import com.patriot.fourlipsclover.chat.dto.response.ChattingListResponse;
import com.patriot.fourlipsclover.chat.service.ChatService;
import com.patriot.fourlipsclover.config.CustomUserDetails;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.async.DeferredResult;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    // 공통 인증 정보 추출 메서드
    private long getCurrentMemberId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        return userDetails.getMember().getMemberId();
    }

    // 채팅방 인원 추가(해당 그룹 인원 목록 리스트에서 추가)
    @PostMapping("/invite/{matchId}")
    public ResponseEntity<Void> inviteMembersToChat(@PathVariable Integer matchId,
                                                    @RequestBody InviteMembersRequest memberIds) {
        chatService.inviteMembersToChat(matchId, memberIds);
        return ResponseEntity.ok().build();
    }

    // 소속된 채팅방 목록 조회
    @GetMapping("/rooms")
    public ResponseEntity<List<ChattingListResponse>> getChatRooms() {
        long currentMemberId = getCurrentMemberId();
        List<ChattingListResponse> chatRooms = chatService.getChatRoomsByMember(currentMemberId);
        return ResponseEntity.ok(chatRooms);
    }

    // 본인이 소속된 채팅방 중 1개 입장
    @GetMapping("/room/{chatRoomId}")
    public ResponseEntity<ChatRoomResponse> getChatRoom(@PathVariable Integer chatRoomId,
                                                        @RequestParam int offset, @RequestParam int limit) {
        long currentMemberId = getCurrentMemberId(); // 현재 사용자 ID
        ChatRoomResponse chatRoomResponse = chatService.getChatRoomWithMessages(chatRoomId, currentMemberId, offset, limit);
        return ResponseEntity.ok(chatRoomResponse);
    }

    // 텍스트 메세지 전송
    @PostMapping("/send/{chatRoomId}")
    public ResponseEntity<ChatMessageResponse> sendMessage(@PathVariable Integer chatRoomId,
                                                           @RequestBody ChatMessageRequest request) {
        ChatMessageResponse message = chatService.sendMessage(chatRoomId, request.getSenderId(), request.getMessageContent());
        return ResponseEntity.ok(message);
    }

    // 이미지 메시지 전송
    @PostMapping("/send/{chatRoomId}/images")
    public ChatMessageResponse sendImageMessage(@PathVariable Integer chatRoomId,
                                                @RequestParam String messageContent,
                                                @RequestParam List<MultipartFile> images) throws Exception {
        long currentMemberId = getCurrentMemberId();
        return chatService.sendImageMessage(chatRoomId, currentMemberId, messageContent, images);
    }

    // 롱풀링 방식으로 채팅 메시지 가져오기
    @GetMapping("/{chatRoomId}/messages")
    public DeferredResult<ResponseEntity<List<ChatMessageResponse>>> getChatMessages(
            @PathVariable Integer chatRoomId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime after) {

        // 30초 타임아웃 설정
        DeferredResult<ResponseEntity<List<ChatMessageResponse>>> deferredResult = new DeferredResult<>(30000L);

        // after 값이 없으면 기본값 설정 (예: 현재 시간 - 1분)
        if (after == null) {
            after = LocalDateTime.now().minusMinutes(1);
        }

        // 별도 스레드에서 롱 폴링 로직 실행
        LocalDateTime finalAfter = after;
        new Thread(() -> {
            while (!deferredResult.isSetOrExpired()) {
                List<ChatMessageResponse> messages = chatService.getMessagesWithDetails(chatRoomId, finalAfter);
                if (!messages.isEmpty()) {
                    deferredResult.setResult(ResponseEntity.ok(messages));
                    break;
                }
                try {
                    Thread.sleep(1000); // 1초마다 확인
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    deferredResult.setErrorResult(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build());
                }
            }
        }).start();

        deferredResult.onTimeout(() -> deferredResult.setResult(ResponseEntity.ok(new ArrayList<>())));
        return deferredResult;
    }

//    @DeleteMapping("/room/{chatRoomId}/leave")
//    public ResponseEntity<Void> leaveChatRoom(@PathVariable Integer chatRoomId) {
//        long currentMemberId = getCurrentMemberId();  // 현재 로그인된 사용자 ID
//        chatService.leaveChatRoom(chatRoomId, currentMemberId);  // 채팅방 나가기
//        return ResponseEntity.ok().build();
//    }

}
