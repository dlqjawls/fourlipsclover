package com.patriot.fourlipsclover.match.service;

import com.patriot.fourlipsclover.exception.MatchBusinessException;
import com.patriot.fourlipsclover.exception.UserNotFoundException;
import com.patriot.fourlipsclover.group.repository.GroupRepository;
import com.patriot.fourlipsclover.match.dto.request.MatchCreateRequest;
import com.patriot.fourlipsclover.match.entity.ApprovalStatus;
import com.patriot.fourlipsclover.match.entity.GuideRequestForm;
import com.patriot.fourlipsclover.match.entity.Match;
import com.patriot.fourlipsclover.match.entity.MatchTag;
import com.patriot.fourlipsclover.match.repository.GuideRequestFormRepository;
import com.patriot.fourlipsclover.match.repository.MatchRepository;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.payment.service.PaymentService;
import com.patriot.fourlipsclover.tag.entity.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final MatchRepository matchRepository;
    private final MemberRepository memberRepository;
    private final GuideRequestFormRepository guideRequestFormRepository;
    private final GroupRepository groupRepository;
    private final PaymentService paymentService;

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
        GuideRequestForm form = request.getGuideRequestForm();
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

//        // itemName 검증 (상품명이 비어있으면 안 됨)
//        if (request.getItemName() == null || request.getItemName().isEmpty()) {
//            throw new MatchBusinessException("상품명은 필수입니다.");
//        }

//        // quantity 검증 (수량은 1 이상이어야 함)
//        try {
//            int quantity = Integer.parseInt(request.getQuantity());
//            if (quantity < 1) {
//                throw new MatchBusinessException("수량은 1 이상이어야 합니다.");
//            }
//        } catch (NumberFormatException e) {
//            throw new MatchBusinessException("수량은 유효한 숫자여야 합니다.");
//        }

//        // totalAmount 검증 (금액은 유효한 숫자여야 함)
//        try {
//            double totalAmount = Double.parseDouble(request.getTotalAmount().replace(",", ""));
//            if (totalAmount <= 0) {
//                throw new MatchBusinessException("결제 금액은 0보다 커야 합니다.");
//            }
//        } catch (NumberFormatException e) {
//            throw new MatchBusinessException("금액은 유효한 숫자여야 합니다.");
//        }

    }

    // 결제 승인 후, Match 엔티티에 partnerOrderId와 다른 정보들까지 저장하는 메서드
    @Transactional
    public Match createMatchAfterPayment(String partnerOrderId, MatchCreateRequest request, long currentMemberId) {
        // 결제 성공 시, Match 엔티티를 생성하고 partnerOrderId를 설정
        Match match = new Match();

        // 회원 ID, 지역, 가이드, 기타 정보 설정
        match.setMemberId(currentMemberId);  // 현재 로그인한 사용자의 ID를 사용
        match.setRegion(request.getRegion());    // 신청서에서 지역 정보 저장
        match.setGuide(request.getGuide());      // 신청서에서 가이드 정보 저장
        match.setStatus(ApprovalStatus.PENDING);
        match.setPartnerOrderId(partnerOrderId);  // 결제에서 받은 partnerOrderId 저장

        // 가이드 신청서 (GuideRequestForm) 저장
        GuideRequestForm guideRequestForm = request.getGuideRequestForm();
        if (guideRequestForm != null) {
            guideRequestForm.setCreatedAt(LocalDateTime.now());
            guideRequestFormRepository.save(guideRequestForm);  // 가이드 신청서 저장
            match.setGuideRequestForm(guideRequestForm);  // 매칭과 연결
        }

        // 태그 처리: MatchCreateRequest에서 받은 태그를 MatchTag로 변환하여 저장
        List<MatchTag> matchTags = new ArrayList<>();
        for (MatchTag matchTag : request.getTags()) {
            Tag tag = matchTag.getTag();  // tag를 얻은 후
            matchTag.setMatch(match);  // Match 객체와 연결
            matchTag.setTag(tag);  // Tag와 연결
            matchTags.add(matchTag);  // 생성한 MatchTag를 리스트에 추가
        }
        match.setMatchTags(matchTags);  // matchTags 필드에 추가

        return matchRepository.save(match);  // 매칭 저장
    }

}
