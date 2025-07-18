package com.patriot.fourlipsclover.match.service;

import com.patriot.fourlipsclover.chat.entity.ChatMember;
import com.patriot.fourlipsclover.chat.entity.ChatMemberId;
import com.patriot.fourlipsclover.chat.entity.ChatRoom;
import com.patriot.fourlipsclover.chat.repository.ChatMemberRepository;
import com.patriot.fourlipsclover.chat.repository.ChatRoomRepository;
import com.patriot.fourlipsclover.exception.*;
import com.patriot.fourlipsclover.group.entity.Group;
import com.patriot.fourlipsclover.group.repository.GroupRepository;
import com.patriot.fourlipsclover.group.service.GroupService;
import com.patriot.fourlipsclover.match.dto.mapper.MatchMapper;
import com.patriot.fourlipsclover.match.dto.request.GuideRequestFormRequest;
import com.patriot.fourlipsclover.match.dto.request.LocalsProposalRequest;
import com.patriot.fourlipsclover.match.dto.request.MatchCreateRequest;
import com.patriot.fourlipsclover.match.dto.request.TagRequest;
import com.patriot.fourlipsclover.match.dto.response.*;
import com.patriot.fourlipsclover.match.entity.*;
import com.patriot.fourlipsclover.match.repository.GuideRequestFormRepository;
import com.patriot.fourlipsclover.match.repository.LocalsProposalRepository;
import com.patriot.fourlipsclover.match.repository.MatchRepository;
import com.patriot.fourlipsclover.match.repository.MatchTagRepository;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.payment.dto.response.PaymentCancelResponse;
import com.patriot.fourlipsclover.payment.entity.PaymentApproval;
import com.patriot.fourlipsclover.payment.repository.PaymentApprovalRepository;
import com.patriot.fourlipsclover.payment.service.PaymentService;
import com.patriot.fourlipsclover.restaurant.entity.Region;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.repository.RegionRepository;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantJpaRepository;
import com.patriot.fourlipsclover.tag.entity.Tag;
import com.patriot.fourlipsclover.tag.repository.TagRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final MatchRepository matchRepository;
    private final MemberRepository memberRepository;
    private final GuideRequestFormRepository guideRequestFormRepository;
    private final PaymentService paymentService;
    private final PaymentApprovalRepository paymentApprovalRepository;
    private final LocalsProposalRepository localsProposalRepository;
    private final RestaurantJpaRepository restaurantJpaRepository;
    private final GroupService groupService;
    private final GroupRepository groupRepository;
    private static final Logger logger = LoggerFactory.getLogger(MatchService.class);
    private final MatchTagRepository matchTagRepository;
    private final TagRepository tagRepository;
    private final MatchMapper matchMapper;
    private final RegionRepository regionRepository;
    private final ChatMemberRepository chatMemberRepository;
    private final ChatRoomRepository chatRoomRepository;

    public void validateMatchRequest(MatchCreateRequest request, long memberId) {
        boolean isMember = memberRepository.existsById(memberId);
        if (!isMember) {
            throw new UserNotFoundException("유효하지 않은 멤버입니다.");
        }
        // 태그 검증 (1-3개)
        if (request.getTags() == null ||
                request.getTags().isEmpty() ||
                request.getTags().size() > 3) {
            throw new MatchBusinessException("태그는 1-3개 사이여야 합니다.");
        }

        // 지역 정보 검증
        if (request.getRegion() == null) {
            throw new MatchBusinessException("지역 정보는 필수입니다.");
        }

        // 가이드 정보 검증
        Long guideId = request.getGuide().getMemberId();
        if (guideId == null) {
            throw new MatchBusinessException("가이드 선택은 필수입니다.");
        }

        // 가이드가 유효한 멤버인지 확인
        boolean isGuideMember = memberRepository.existsById(guideId);
        if (!isGuideMember) {
            throw new UserNotFoundException("유효하지 않은 멤버입니다.");
        }

        // 가이드 신청서 검증
        GuideRequestFormRequest form = request.getGuideRequestForm();
        if (form == null) {
            throw new MatchBusinessException("가이드 신청서 작성은 필수입니다.");
        }

        // 가이드 신청서 필드 검증 (지역, 교통수단, 음식 취향 등)
        if (form.getTransportation() == null || form.getTransportation().isEmpty()) {
            throw new MatchBusinessException("교통수단을 선택해야 합니다.");
        }

        if (form.getFoodPreference() == null || form.getFoodPreference().isEmpty()) {
            throw new MatchBusinessException("음식 종류를 선택해야 합니다.");
        }

        if (form.getTastePreference() == null || form.getTastePreference().isEmpty()) {
            throw new MatchBusinessException("맛 취향을 선택해야 합니다.");
        }

        if (form.getRequirements() == null || form.getRequirements().isEmpty()) {
            throw new MatchBusinessException("요청사항을 작성해야 합니다.");
        }

    }

    @Transactional
    public Match createMatchAfterPayment(String partnerOrderId, MatchCreateRequest request, long currentMemberId) {
        logger.info("매치 생성 LOG, MatchCreateRequest = {}", request);
        GuideRequestForm guideRequestForm = matchMapper.toGuideRequestForm(request.getGuideRequestForm());
        // 그룹이 선택되지 않았을 경우 새로운 그룹을 생성하고 할당
        if (request.getGuideRequestForm().getGroupId() == null) {
            // 그룹 처리: 그룹이 선택되지 않으면 "나홀로 여행" 그룹을 생성하고 할당
            groupService.handleGroupAssignment(guideRequestForm, currentMemberId); // 그룹 생성 후 guideRequestForm에 그룹 설정
        } else {
            // 이미 그룹 정보가 존재하면 해당 groupId를 사용하여 그룹을 설정
            Integer groupId = request.getGuideRequestForm().getGroupId();  // 입력된 groupId로 그룹 정보 설정
            Group existingGroup = groupRepository.findById(groupId)
                    .orElseThrow(() -> new MatchBusinessException("유효하지 않은 그룹입니다."));  // 그룹이 존재하지 않으면 예외 처리
            guideRequestForm.setGroup(existingGroup);
        }

        // GuideRequestForm을 DB에 저장 (새로 생성된 객체이므로 저장해야 함)
        guideRequestFormRepository.save(guideRequestForm);
        Region region = regionRepository.findByRegionId(request.getRegion().getRegionId());
        Member guide = memberRepository.findByMemberId(request.getGuide().getMemberId());
        // 3. Match 엔티티 생성
        Match match = Match.builder()
                .memberId(currentMemberId) // 매칭 요청자 ID
                .region(region) // 지역 정보
                .guide(guide) // 가이드 정보
                .guideRequestForm(guideRequestForm) // 가이드 신청서 연결
                .status(ApprovalStatus.PENDING) // 기본 승인 상태 (대기)
                .partnerOrderId(partnerOrderId) // 결제 번호
                .createdAt(LocalDateTime.now())
                .build();

        // 4. Match 저장 (match_id가 생성됨)
        matchRepository.save(match);
        logger.info("프론트의 태그 확인 LOG, MatchCreateRequest = {}", request.getTags());

        // 5. MatchTag 저장 (태그 처리)
        for (TagRequest matchTag : request.getTags()) {
            // 프론트에서 받은 tagId를 기반으로 Tag 객체를 찾아야 함
            Long tagId = matchTag.getTagId();  // tagId를 가져옴
            if (tagId == null) {
                throw new IllegalArgumentException("Tag ID는 필수입니다.");
            }

            // Tag 객체를 찾아서, 없으면 예외 처리
            Tag tagEntity = tagRepository.findById(tagId)
                    .orElseThrow(() -> new IllegalArgumentException("유효하지 않은 tagId: " + tagId));

            // MatchTag 객체 생성
            MatchTag newMatchTag = MatchTag.builder()
                    .match(match) // 새로 생성된 match와 연결
                    .tag(tagEntity) // Tag 엔티티 연결
                    .build();

            // MatchTag 저장
            matchTagRepository.save(newMatchTag);
        }

        return match; // 생성된 Match 객체 반환
    }

    // 신청자 - 매칭 신청 내역 조회(현지인 수락 상태 상관없이 전체 신청 목록 조회)
    public List<MatchListResponse> getMatchListByMemberId(long currentMemberId) {
        // 현재 멤버가 존재하는지 확인
        boolean memberExists = memberRepository.existsById(currentMemberId);
        if (!memberExists) {
            throw new MemberNotFoundException("유효하지 않은 회원입니다.");
        }

        // 현재 멤버가 신청한 매칭 리스트를 가져옴
        List<Match> matches = matchRepository.findByMemberId(currentMemberId);  // matchRepository에서 조회

        // 매칭 리스트가 비어 있으면 예외 처리
        if (matches.isEmpty()) {
            throw new MatchNotFoundException("사용자 - 수락 상태 상관x, 매칭 신청 내역이 없습니다.");
        }

        List<MatchListResponse> responseList = new ArrayList<>();

        for (Match match : matches) {
            Integer matchId = match.getMatchId();
            String regionName = match.getRegion().getName();  // region_name
            String guideNickname = match.getGuide().getNickname();  // guide의 nickname
            LocalDateTime createdAt = match.getCreatedAt();  // match 생성일
            LocalDate startDate = match.getGuideRequestForm().getStartDate();  // start_date
            LocalDate endDate = match.getGuideRequestForm().getEndDate();  // end_date
            String status = match.getStatus().name();  // 상태 (PENDING, CONFIRMED, REJECTED)

            MatchListResponse response = new MatchListResponse(matchId, regionName, guideNickname, createdAt, startDate, endDate, status);

            responseList.add(response);
        }

        return responseList;
    }

    // 신청자 - 매칭 신청 상세 조회
    public MatchDetailResponse getMatchDetail(int matchId, long currentMemberId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new MatchNotFoundException("매칭을 찾을 수 없습니다."));

        // 현재 사용자가 해당 매칭의 신청자(member_id)와 일치하는지 확인
        if (match.getMemberId() != currentMemberId) {
            throw new UnauthorizedAccessException("매칭 신청자만 신청 상세 내역을 확인할 수 있습니다.");
        }

        // 응답 DTO 생성 및 데이터 매핑
        MatchDetailResponse response = new MatchDetailResponse();
        response.setRegionName(match.getRegion().getName());
        response.setGuideNickname(match.getGuide().getNickname());
        response.setStatus(match.getStatus().name());

        // 가이드 신청서(GuideRequestForm) 정보 매핑
        GuideRequestForm form = match.getGuideRequestForm();
        if (form != null) {
            response.setMatchId(matchId);
            response.setFoodPreference(form.getFoodPreference());
            response.setRequirements(form.getRequirements());
            response.setTastePreference(form.getTastePreference());
            response.setTransportation(form.getTransportation());
            response.setStartDate(form.getStartDate());
            response.setEndDate(form.getEndDate());
            response.setCreatedAt(form.getCreatedAt());
        }

        return response;
    }

    // 신청자 - 결제 취소 처리
    @Transactional
    public void cancelMatch(int matchId, long currentMemberId) {
        // 1. 매칭 엔티티 조회 및 소유자 확인
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new MatchNotFoundException("매칭을 찾을 수 없습니다."));
        if (match.getMemberId() != currentMemberId) {
            throw new UnauthorizedAccessException("매칭 신청자만 결제 취소할 수 있습니다.");
        }

        // 2. 매칭 상태가 PENDING인지 확인
        if (match.getStatus() != ApprovalStatus.PENDING) {
            throw new MatchBusinessException("승인 또는 거절된 매칭입니다.");
        }

        // 3. PaymentApproval 정보 조회 (match의 partnerOrderId를 이용)
        PaymentApproval paymentApproval = (PaymentApproval) paymentApprovalRepository
                .findByPartnerOrderId(match.getPartnerOrderId())
                .orElseThrow(() -> new PaymentNotFoundException("매칭에 해당하는 결제 정보를 찾을 수 없습니다."));

        // PaymentApproval에서 tid와 결제 금액(cancelAmount)을 가져옴
        String tid = paymentApproval.getTid();
        Integer cancelAmount = paymentApproval.getAmount().getTotal();
        Integer cancelTaxFreeAmount = 0;  // 취소 비과세 금액이 없다면 0으로 처리

        // 4. 결제 취소 요청 (cid는 PaymentService에 정의된 상수 "TC0ONETIME" 사용)
        PaymentCancelResponse cancelResponse = paymentService.cancel("TC0ONETIME", tid, cancelAmount, cancelTaxFreeAmount);

        // 결제 취소 성공 시 매칭 상태를 업데이트 (사용자 취소된 매칭은 CANCELED 상태로 변경)
        match.setStatus(ApprovalStatus.CANCELED);
        match.setUpdatedAt(LocalDateTime.now());

        // 업데이트된 매칭 정보 저장
        matchRepository.save(match);
    }

    // 현지인 - 매칭 신청 들어온 목록 조회
    @Transactional(readOnly = true)
    public List<LocalsMatchListResponse> getLocalsMatchListByGuideId(long guideId) {
        // 현재 멤버가 존재하는지 확인
        boolean memberExists = memberRepository.existsById(guideId);
        if (!memberExists) {
            throw new MemberNotFoundException("유효하지 않은 회원입니다.");
        }

        // 2. 해당 가이드로 신청된 매칭 목록 조회
        List<Match> matches = matchRepository.findByGuide_MemberIdAndStatus(guideId, ApprovalStatus.PENDING);
        if (matches.isEmpty()) {
            throw new MatchNotFoundException("현지인 - 신청 들어온 내역이 없습니다.");
        }

        // 조회된 Match 엔티티들을 LocalsMatchListResponse DTO로 변환
        return matches.stream().map(match -> {
            GuideRequestForm requestForm = match.getGuideRequestForm();
            return new LocalsMatchListResponse(
                    match.getMatchId(),
                    requestForm,                           // GuideRequestForm 객체를 그대로 전달
                    match.getMemberId(),                   // 신청자 ID
                    match.getRegion().getName(),           // 지역 이름
                    match.getCreatedAt(),                  // 매칭 생성 일시
                    match.getStatus().name(),              // 상태를 문자열로 반환
                    2000                                   // 임시 팁 금액 (아이템 테이블 추가하고 값 가져오기)
            );
        }).collect(Collectors.toList());
    }

    // 현지인 - 매칭 수락
    @Transactional
    public LocalsConfirmResponse processAcceptMatch(int matchId, long currentMemberId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new MatchNotFoundException("매칭을 찾을 수 없습니다."));
        if (match.getGuide().getMemberId() != currentMemberId) {
            throw new UnauthorizedAccessException("현지인만 매칭을 수락할 수 있습니다.");
        }
        if (match.getStatus() != ApprovalStatus.PENDING) {
            throw new MatchBusinessException("이미 처리된 매칭입니다.");
        }

        // 매칭 상태를 CONFIRMED로 변경
        match.setStatus(ApprovalStatus.CONFIRMED);
        match.setUpdatedAt(LocalDateTime.now());
        matchRepository.save(match);

        // 채팅방이 이미 존재하는지 확인
        ChatRoom existingChatRoom = chatRoomRepository.findByMatch_MatchId(matchId);
        if (existingChatRoom != null) {
            // 이미 존재하는 채팅방이 있으면 그 채팅방을 사용
            addMemberToChatRoom(existingChatRoom, match.getMemberId()); // 신청자 추가
            addMemberToChatRoom(existingChatRoom, currentMemberId); // 현지인 추가
            return buildLocalsConfirmResponse(match, matchId);
        }

        // 채팅방 생성
        ChatRoom chatRoom = new ChatRoom();
        chatRoom.setName(match.getRegion().getName() + "로 떠나요");
        chatRoom.setMatch(match);  // Match와 연결
        chatRoom.setCreatedAt(LocalDateTime.now());
        chatRoomRepository.save(chatRoom); // 채팅방 저장

        // 매칭 신청자와 가이드를 채팅방 멤버로 추가
        addMemberToChatRoom(chatRoom, match.getMemberId()); // 매칭 신청자 추가
        addMemberToChatRoom(chatRoom, currentMemberId); // 현지인 가이드 추가

        return buildLocalsConfirmResponse(match, matchId);
    }

    // 채팅방 멤버 추가 메서드
    private void addMemberToChatRoom(ChatRoom chatRoom, Long memberId) {
        // 1. 멤버를 조회합니다.
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new MemberNotFoundException("멤버를 찾을 수 없습니다: " + memberId));

        // 2. ChatMemberId를 생성하여 복합키를 설정합니다.
        ChatMemberId chatMemberId = new ChatMemberId();
        chatMemberId.setChatRoomId(chatRoom.getChatRoomId()); // 채팅방 ID 설정
        chatMemberId.setMemberId(member.getMemberId()); // 멤버 ID 설정

        // 3. ChatMember 객체를 생성하여 채팅방에 멤버를 추가합니다.
        ChatMember chatMember = new ChatMember();
        chatMember.setId(chatMemberId); // 복합키 설정
        chatMember.setChatRoom(chatRoom); // 채팅방 설정
        chatMember.setMember(member); // 멤버 설정
        chatMember.setJoinedAt(LocalDateTime.now()); // 입장 시간 설정

        // 4. ChatMember 객체를 DB에 저장합니다.
        chatMemberRepository.save(chatMember);
    }

    // LocalsConfirmResponse 객체를 생성하는 메서드
    private LocalsConfirmResponse buildLocalsConfirmResponse(Match match, int matchId) {
        LocalsConfirmResponse response = new LocalsConfirmResponse();
        response.setRegionName(match.getRegion().getName());
        response.setMatchCreatorId(match.getMemberId());
        response.setStatus(match.getStatus().name());
        response.setMatchId(matchId);

        // GuideRequestForm 정보 매핑 (null 체크)
        if (match.getGuideRequestForm() != null) {
            response.setFoodPreference(match.getGuideRequestForm().getFoodPreference());
            response.setRequirements(match.getGuideRequestForm().getRequirements());
            response.setTastePreference(match.getGuideRequestForm().getTastePreference());
            response.setTransportation(match.getGuideRequestForm().getTransportation());
            response.setStartDate(match.getGuideRequestForm().getStartDate());
            response.setEndDate(match.getGuideRequestForm().getEndDate());
            response.setCreatedAt(match.getUpdatedAt());
        }

        return response;
    }

    // 현지인 - CONFIRMED 상태인 매칭 목록 조회
    @Transactional(readOnly = true)
    public List<LocalsMatchListResponse> getConfirmedMatchesForGuide(long guideId) {
        if (!memberRepository.existsById(guideId)) {
            throw new MemberNotFoundException("현지인 회원이 존재하지 않습니다.");
        }

        List<Match> matches = matchRepository.findByGuide_MemberIdAndStatus(guideId, ApprovalStatus.CONFIRMED);
        if (matches.isEmpty()) {
            throw new MatchBusinessException("CONFIRMED 상태인 매칭 내역이 없습니다.");
        }

        return matches.stream().map(match -> new LocalsMatchListResponse(
                match.getMatchId(),
                match.getGuideRequestForm(),
                match.getMemberId(),
                match.getRegion().getName(),
                match.getCreatedAt(),
                match.getStatus().name(),
                2000
        )).collect(Collectors.toList());
    }

    // 현지인 - CONFIRMED 상태 매칭에 대해 가이드가 기획서를 작성하는 API
    @Transactional
    public LocalsProposalResponse createLocalsProposal(LocalsProposalRequest request, long currentMemberId) {
        Match match = matchRepository.findById(request.getMatchId())
                .orElseThrow(() -> new MatchBusinessException("매칭을 찾을 수 없습니다."));
        if (!match.getGuide().getMemberId().equals(currentMemberId)) {
            throw new UnauthorizedAccessException("해당 매칭의 가이드만 기획서를 작성할 수 있습니다.");
        }
        if (match.getStatus() != ApprovalStatus.CONFIRMED) {
            throw new MatchBusinessException("CONFIRMED 상태의 매칭만 기획서를 작성할 수 있습니다.");
        }
        localsProposalRepository.findByMatch_MatchId(request.getMatchId())
                .ifPresent(existing -> {
                    throw new MatchBusinessException("이미 기획서가 작성되었습니다.");
                });

        // 추천 식당 목록 조회
        List<Restaurant> restaurants = restaurantJpaRepository.findAllById(request.getRestaurantIds());

        // LocalsProposal 엔티티 생성 및 값 설정
        LocalsProposal localsProposal = new LocalsProposal();
        localsProposal.setMatch(match);
        localsProposal.setRestaurantList(restaurants); // Restaurant 객체 리스트 설정
        localsProposal.setRecommendMenu(request.getRecommendMenu());
        localsProposal.setDescription(request.getDescription());

        // LocalsProposal 엔티티 저장
        LocalsProposal savedProposal = localsProposalRepository.save(localsProposal);

        // DTO 생성: 저장된 엔티티에서 식당 ID 리스트 추출
        List<Integer> restaurantIds = savedProposal.getRestaurantList()
                .stream()
                .map(Restaurant::getRestaurantId)
                .collect(Collectors.toList());

        return new LocalsProposalResponse(
                savedProposal.getProposalId(),
                savedProposal.getMatch().getMatchId(),
                restaurantIds, // Integer 리스트 반환
                savedProposal.getRecommendMenu(),
                savedProposal.getDescription()
        );
    }

    // 현지인 - 매칭 거절
    @Transactional
    public void rejectMatch(int matchId, long currentMemberId) {
        // 매칭 엔티티 조회
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new MatchBusinessException("매칭을 찾을 수 없습니다."));

        // 현재 로그인한 가이드가 해당 매칭의 가이드인지 확인
        if (!match.getGuide().getMemberId().equals(currentMemberId)) {
            throw new UnauthorizedAccessException("본인의 매칭만 거절할 수 있습니다.");
        }

        // 매칭 상태가 PENDING인지 확인
        if (match.getStatus() != ApprovalStatus.PENDING) {
            throw new MatchBusinessException("매칭이 PENDING 상태가 아니므로 거절할 수 없습니다.");
        }

        // 매칭 거절 처리: 상태를 REJECTED로 변경, updatedAt 설정
        match.setStatus(ApprovalStatus.REJECTED);
        match.setUpdatedAt(LocalDateTime.now());

        // 결제 취소 처리: 매칭에 결제 정보가 존재하면 진행
        if (match.getPartnerOrderId() != null) {
            PaymentApproval paymentApproval = (PaymentApproval) paymentApprovalRepository
                    .findByPartnerOrderId(match.getPartnerOrderId())
                    .orElseThrow(() -> new PaymentNotFoundException("해당 매칭의 결제 정보를 찾을 수 없습니다."));

            String tid = paymentApproval.getTid();
            Integer cancelAmount = paymentApproval.getAmount().getTotal();
            Integer cancelTaxFreeAmount = 0; // 취소 비과세 금액이 없으면 0으로 처리

            PaymentCancelResponse cancelResponse = paymentService.cancel("TC0ONETIME", tid, cancelAmount, cancelTaxFreeAmount);
            if (cancelResponse == null) {
                throw new MatchBusinessException("결제 취소에 실패하였습니다.");
            }
        }

        // 변경된 매칭 정보 저장
        match.setStatus(ApprovalStatus.REJECTED);
        match.setUpdatedAt(LocalDateTime.now());
        matchRepository.save(match);
    }
}
