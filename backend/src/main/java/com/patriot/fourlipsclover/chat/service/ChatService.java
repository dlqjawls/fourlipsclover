package com.patriot.fourlipsclover.chat.service;

import com.patriot.fourlipsclover.chat.dto.request.InviteMembersRequest;
import com.patriot.fourlipsclover.chat.dto.response.ChatMemberResponse;
import com.patriot.fourlipsclover.chat.dto.response.ChatMessageResponse;
import com.patriot.fourlipsclover.chat.dto.response.ChatRoomResponse;
import com.patriot.fourlipsclover.chat.dto.response.ChattingListResponse;
import com.patriot.fourlipsclover.chat.entity.*;
import com.patriot.fourlipsclover.chat.repository.ChatMemberRepository;
import com.patriot.fourlipsclover.chat.repository.ChatMessageRepository;
import com.patriot.fourlipsclover.chat.repository.ChatRoomRepository;
import com.patriot.fourlipsclover.exception.AlreadyExistException;
import com.patriot.fourlipsclover.exception.MatchNotFoundException;
import com.patriot.fourlipsclover.exception.MemberNotFoundException;
import com.patriot.fourlipsclover.exception.NotFoundException;
import com.patriot.fourlipsclover.group.entity.Group;
import com.patriot.fourlipsclover.match.entity.Match;
import com.patriot.fourlipsclover.match.repository.MatchRepository;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final ChatMemberRepository chatMemberRepository;
    private final MemberRepository memberRepository;
    private final MatchRepository matchRepository;
    private final ChatImageService chatImageService;


    // 특정 chatRoomId의, after 이후의 메시지를 조회하는 메서드
    @Transactional
    public List<ChatMessage> getMessages(Integer chatRoomId, LocalDateTime after) {
        return chatMessageRepository.findByChatRoom_ChatRoomIdAndCreatedAtAfter(chatRoomId, after);
    }

    // ChatService에서 메시지를 가져올 때 DTO로 변환해서 반환
    @Transactional
    public List<ChatMessageResponse> getMessagesWithDetails(Integer chatRoomId, LocalDateTime after) {
        // 채팅방에 소속된 메시지 목록 조회
        List<ChatMessage> chatMessages = chatMessageRepository.findByChatRoom_ChatRoomIdAndCreatedAtAfter(chatRoomId, after);

        // 메시지 목록을 response 객체로 변환하여 반환
        return chatMessages.stream()
                .map(message -> new ChatMessageResponse(
                        message.getMessageId(),
                        message.getChatRoom().getChatRoomId(),
                        message.getSender().getMemberId(),
                        message.getSender().getNickname(),
                        message.getSender().getProfileUrl(),
                        message.getMessageContent(),
                        message.getMessageType(),
                        message.getImageUrls(),
                        message.getCreatedAt()))
                .collect(Collectors.toList());
    }

    @Transactional
    public void inviteMembersToChat(Integer matchId, InviteMembersRequest request) {
        // matchId로 매칭 찾기
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new MatchNotFoundException("매칭을 찾을 수 없습니다.: " + matchId));

        // 매칭에 해당하는 채팅방 찾기
        ChatRoom chatRoom = chatRoomRepository.findByMatch(match)
                .orElseThrow(() -> new NotFoundException("매치 아이디에 해당하는 채팅방을 찾을 수 없습니다.: " + matchId));

        // 소속 그룹에 있는 멤버 채팅방에 추가(매칭 신청자만 가능하도록 해야할듯)
        for (Long memberId : request.getMemberIds()) {
            Member member = memberRepository.findById(memberId)
                    .orElseThrow(() -> new MemberNotFoundException("멤버를 확인할 수 없습니다.: " + memberId));

            // 이미 해당 채팅방에 멤버가 존재하는지 체크
            boolean alreadyMember = chatMemberRepository.existsByChatRoom_ChatRoomIdAndMember_MemberId(chatRoom.getChatRoomId(), memberId);
            if (alreadyMember) {
                throw new AlreadyExistException("해당 멤버는 이미 채팅에 참여하고 있습니다.: " + memberId);
            }

            // ChatMemberId 생성
            ChatMemberId chatMemberId = new ChatMemberId(chatRoom.getChatRoomId(), memberId);

            // 채팅방 인원 추가
            ChatMember chatMember = new ChatMember();
            chatMember.setId(chatMemberId); // 여기서 ID를 설정합니다.
            chatMember.setChatRoom(chatRoom);
            chatMember.setMember(member);
            chatMember.setJoinedAt(LocalDateTime.now());

            chatMemberRepository.save(chatMember);
        }
    }

    // 소속된 채팅방 전체 목록 조회
    @Transactional
    public List<ChattingListResponse> getChatRoomsByMember(long currentMemberId) {
        List<ChatMember> chatMembers = chatMemberRepository.findByMember_MemberId(currentMemberId); // 채팅방에 소속된 멤버들 찾기

        // ChatRoom 목록을 ChattingListResponse로 변환
        return chatMembers.stream()
                .map(chatMember -> {
                    ChatRoom chatRoom = chatMember.getChatRoom();  // ChatMember에서 ChatRoom 추출
                    int participantNum = chatMemberRepository.countByChatRoom_ChatRoomId(chatRoom.getChatRoomId()); // 채팅방 참여자 수 조회

                    // 채팅방에 해당하는 matchId와 groupId를 가져옵니다.
                    Integer matchId = null;
                    Integer groupId = null;

                    // 채팅방에 해당하는 매칭이 있는지 확인
                    if (chatRoom.getMatch() != null) {
                        matchId = chatRoom.getMatch().getMatchId();
                    }

                    // 채팅방이 소속된 그룹을 가져옵니다.
                    if (chatRoom.getMatch() != null && chatRoom.getMatch().getGuideRequestForm() != null) {
                        Group group = chatRoom.getMatch().getGuideRequestForm().getGroup();
                        if (group != null) {
                            groupId = group.getGroupId();
                        }
                    }

                    return new ChattingListResponse(
                            chatRoom.getChatRoomId(),
                            chatRoom.getName(),
                            participantNum,
                            matchId,
                            groupId
                    );
                })
                .collect(Collectors.toList());
    }

    // 소속 채팅방 1개 입장, 메세지 얼마나 가져올지 offset, limit 결정함
    @Transactional
    public ChatRoomResponse getChatRoomWithMessages(Integer chatRoomId, long currentMemberId, int offset, int limit) {
        // 채팅방 조회
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new IllegalArgumentException("Chat room not found for chatRoomId: " + chatRoomId));

        // 채팅방에 소속된 메시지 목록을 슬라이딩 윈도우 방식으로 조회
        List<ChatMessage> chatMessages = chatMessageRepository.findByChatRoom_ChatRoomIdOrderByCreatedAtAsc(chatRoomId, PageRequest.of(offset, limit));

        // 채팅방에 소속된 멤버 목록 조회
        List<ChatMember> chatMembers = chatMemberRepository.findByChatRoom_ChatRoomId(chatRoomId);

        // 채팅방 참가자 정보 준비
        List<ChatMemberResponse> memberResponses = chatMembers.stream()
                .map(member -> new ChatMemberResponse(
                        member.getMember().getMemberId(),
                        member.getMember().getNickname(),
                        member.getMember().getProfileUrl(), // 회원의 프로필 URL 추가
                        member.getJoinedAt()))
                .collect(Collectors.toList());

        // 채팅 메시지 응답 준비
        List<ChatMessageResponse> messageResponses = chatMessages.stream()
                .map(message -> new ChatMessageResponse(
                        message.getMessageId(),
                        message.getChatRoom().getChatRoomId(),
                        message.getSender().getMemberId(),
                        message.getSender().getNickname(),
                        message.getSender().getProfileUrl(),
                        message.getMessageContent(),
                        message.getMessageType(),
                        message.getImageUrls(),
                        message.getCreatedAt()))
                .collect(Collectors.toList());

        // 롱풀 방식으로 클라이언트에게 반환할 채팅방 정보와 메시지 목록 포함
        return new ChatRoomResponse(
                chatRoom.getChatRoomId(),
                chatRoom.getName(),
                messageResponses,
                memberResponses
        );
    }

    @Transactional
    public ChatMessageResponse sendMessage(Integer chatRoomId, Long senderId, String messageContent) {
        // 특정 채팅방에서 채팅 입력
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new IllegalArgumentException("Chat room not found for chatRoomId: " + chatRoomId));

        Member sender = memberRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("Sender not found for senderId: " + senderId));

        // 새로운 메시지 생성
        ChatMessage message = new ChatMessage();
        message.setChatRoom(chatRoom);
        message.setSender(sender);
        message.setMessageContent(messageContent);
        message.setMessageType(MessageType.TEXT);  // 기본적으로 TEXT 타입으로 설정
        message.setCreatedAt(LocalDateTime.now());

        // 메시지 저장
        ChatMessage savedMessage = chatMessageRepository.save(message);

        // 저장된 메시지를 ChatMessageResponse로 변환하여 반환
        return ChatMessageResponse.builder()
                .messageId(savedMessage.getMessageId())
                .chatRoomId(chatRoom.getChatRoomId())
                .memberId(sender.getMemberId())
                .nickname(sender.getNickname())
                .profileUrl(sender.getProfileUrl())
                .messageContent(savedMessage.getMessageContent())
                .messageType(savedMessage.getMessageType())
                .createdAt(savedMessage.getCreatedAt())
                .build();
    }

    @Transactional
// 이미지 메시지 저장
    public ChatMessageResponse sendImageMessage(Integer chatRoomId, Long senderId, String messageContent, List<MultipartFile> images) throws Exception {
        // 채팅방 및 발신자 정보 조회
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new IllegalArgumentException("Chat room not found"));

        Member sender = memberRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("Sender not found"));

        // 이미지를 MinIO에 업로드하고 URL 반환
        List<String> imageUrls = chatImageService.uploadImages(images).stream()
                .map(imageName -> {
                    try {
                        // 이미지 이름을 MinIO URL로 변환
                        return chatImageService.getImageUrl(imageName);
                    } catch (Exception e) {
                        throw new RuntimeException("url 반환에 실패했습니다.", e);
                    }
                })
                .collect(Collectors.toList());

        // 채팅 메시지 생성
        ChatMessage message = new ChatMessage();
        message.setChatRoom(chatRoom);
        message.setSender(sender);
        message.setMessageContent(messageContent);
        message.setMessageType(MessageType.IMAGE);  // 이미지 메시지 타입
        message.setImageUrls(imageUrls);  // 이미지 URL 저장
        message.setCreatedAt(LocalDateTime.now());

        // 메시지 저장
        ChatMessage savedMessage = chatMessageRepository.save(message);

        // 생성된 메시지를 반환하면서, 이미지 URL도 포함
        return new ChatMessageResponse(
                savedMessage.getMessageId(),
                savedMessage.getChatRoom().getChatRoomId(),
                savedMessage.getSender().getMemberId(),
                savedMessage.getSender().getNickname(),
                savedMessage.getSender().getProfileUrl(),
                savedMessage.getMessageContent(),
                savedMessage.getMessageType(),
                savedMessage.getImageUrls(),  // 이미지 URL 포함
                savedMessage.getCreatedAt()
        );
    }

    @Transactional
    public void leaveChatRoom(Integer chatRoomId, Long memberId) {
        // 채팅방을 찾아옵니다.
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new IllegalArgumentException("채팅방을 찾을 수 없습니다: " + chatRoomId));

        // 채팅방에 속한 멤버를 찾습니다.
        ChatMember chatMember = (ChatMember) chatMemberRepository.findByChatRoom_ChatRoomIdAndMember_MemberId(chatRoomId, memberId)
                .orElseThrow(() -> new IllegalArgumentException("해당 채팅방에서 멤버를 찾을 수 없습니다."));

        // 채팅방에서 해당 멤버를 삭제합니다.
        chatMemberRepository.delete(chatMember);

        // 채팅방에 남은 멤버가 있는지 확인
        long remainingMembersCount = chatMemberRepository.countByChatRoom_ChatRoomId(chatRoomId);

        // 마지막 멤버가 나갔다면 채팅방을 삭제
        if (remainingMembersCount == 0) {
            // 채팅방 삭제 전, 해당 채팅방의 모든 메시지 삭제
            chatMessageRepository.deleteAllByChatRoom_ChatRoomId(chatRoomId);

            chatRoomRepository.delete(chatRoom);
        }
    }

}
