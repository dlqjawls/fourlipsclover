package com.patriot.fourlipsclover.plan.service;

import com.patriot.fourlipsclover.exception.NotPlanMemberException;
import com.patriot.fourlipsclover.exception.PlanNotFoundException;
import com.patriot.fourlipsclover.exception.PlanNoticeNotFoundException;
import com.patriot.fourlipsclover.exception.UnauthorizedAccessException;
import com.patriot.fourlipsclover.group.repository.GroupMemberRepository;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.plan.dto.request.PlanNoticeRequest;
import com.patriot.fourlipsclover.plan.dto.response.PlanNoticeResponse;
import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.entity.PlanNotice;
import com.patriot.fourlipsclover.plan.repository.PlanMemberRepository;
import com.patriot.fourlipsclover.plan.repository.PlanNoticeRepository;
import com.patriot.fourlipsclover.plan.repository.PlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PlanNoticeService {

    private final PlanNoticeRepository planNoticeRepository;
    private final PlanRepository planRepository;
    private final PlanMemberRepository planMemberRepository;
    private final MemberRepository memberRepository;
    private final GroupMemberRepository groupMemberRepository;

    @Transactional
    public PlanNoticeResponse createPlanNotice(Integer planId, long currentMemberId, PlanNoticeRequest request) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new PlanNotFoundException("해당 Plan을 찾을 수 없습니다."));

        boolean isMemberInPlan = planMemberRepository.existsByPlan_PlanIdAndMember_MemberId(planId, currentMemberId);
        if (!isMemberInPlan) {
            throw new NotPlanMemberException("해당 Plan에 소속된 인원만 공지사항을 작성할 수 있습니다.");
        }

        long count = planNoticeRepository.countByPlan_PlanId(planId);
        if (count >= 6) {
            throw new RuntimeException("해당 Plan에는 최대 6개의 공지사항만 작성 가능합니다.");
        }

        Member member = memberRepository.findByMemberId(currentMemberId);

        PlanNotice planNotice = PlanNotice.builder()
                .plan(plan)
                .creator(member)
                .isImportant(request.isImportant())
                .color(request.getColor())
                .content(request.getContent())
                .createdAt(LocalDateTime.now())
                .build();

        PlanNotice savedPlanNotice = planNoticeRepository.save(planNotice);

        return new PlanNoticeResponse(
                savedPlanNotice.getPlanNoticeId(),
                savedPlanNotice.getPlan().getPlanId(),
                savedPlanNotice.getCreator().getMemberId(),
                savedPlanNotice.isImportant(),
                savedPlanNotice.getColor(),
                savedPlanNotice.getContent(),
                savedPlanNotice.getCreatedAt(),
                savedPlanNotice.getUpdatedAt()
        );
    }

    public List<PlanNoticeResponse> getPlanNotices(Integer planId, long currentMemberId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new RuntimeException("해당 Plan을 찾을 수 없습니다."));

        boolean isMemberInGroup = groupMemberRepository.existsByGroup_GroupIdAndMember_MemberId(plan.getGroup().getGroupId(), currentMemberId);
        if (!isMemberInGroup) {
            throw new UnauthorizedAccessException("해당 그룹의 소속 회원만 공지사항을 볼 수 있습니다.");
        }

        List<PlanNotice> planNotices = planNoticeRepository.findByPlan_PlanId(planId);
        if (planNotices.isEmpty()) {
            return Collections.emptyList();
        }

        return planNotices.stream()
                .map(planNotice -> new PlanNoticeResponse(
                        planNotice.getPlanNoticeId(),
                        planNotice.getPlan().getPlanId(),
                        planNotice.getCreator().getMemberId(),
                        planNotice.isImportant(),
                        planNotice.getColor(),
                        planNotice.getContent(),
                        planNotice.getCreatedAt(),
                        planNotice.getUpdatedAt()
                ))
                .collect(Collectors.toList());
    }

    @Transactional
    public PlanNoticeResponse updatePlanNotice(Integer planNoticeId, long currentMemberId, PlanNoticeRequest request) {
        PlanNotice planNotice = planNoticeRepository.findByPlanNoticeId(planNoticeId);
        if (planNotice == null) {
            throw new PlanNoticeNotFoundException("해당 공지사항을 찾을 수 없습니다.");
        }
        if (!planNotice.getCreator().getMemberId().equals(currentMemberId)) {
            throw new UnauthorizedAccessException("공지사항 작성자만 수정 가능합니다.");
        }

        Plan plan = planNotice.getPlan();
        if (plan == null) {
            throw new PlanNotFoundException("해당 Plan을 찾을 수 없습니다.");
        }

        planNotice.setImportant(request.isImportant());
        planNotice.setColor(request.getColor());
        planNotice.setContent(request.getContent());

        PlanNotice updatedPlanNotice = planNoticeRepository.save(planNotice);

        return new PlanNoticeResponse(
                updatedPlanNotice.getPlanNoticeId(),
                updatedPlanNotice.getPlan().getPlanId(),
                updatedPlanNotice.getCreator().getMemberId(),
                updatedPlanNotice.isImportant(),
                updatedPlanNotice.getColor(),
                updatedPlanNotice.getContent(),
                updatedPlanNotice.getCreatedAt(),
                updatedPlanNotice.getUpdatedAt()
        );
    }

    @Transactional
    public void deletePlanNotice(Integer planNoticeId, long currentMemberId) {
        PlanNotice planNotice = planNoticeRepository.findByPlanNoticeId(planNoticeId);
        if (planNotice == null) {
            throw new PlanNoticeNotFoundException("해당 공지사항을 찾을 수 없습니다.");
        }
        if (!planNotice.getCreator().getMemberId().equals(currentMemberId)) {
            throw new UnauthorizedAccessException("공지사항 작성자만 삭제 가능합니다.");
        }

        planNoticeRepository.delete(planNotice);
    }

}
