package com.patriot.fourlipsclover.plan.dto.mapper;

import com.patriot.fourlipsclover.group.entity.Group;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.plan.dto.request.PlanCreateRequest;
import com.patriot.fourlipsclover.plan.dto.response.PlanDetailResponse;
import com.patriot.fourlipsclover.plan.dto.response.PlanListResponse;
import com.patriot.fourlipsclover.plan.dto.response.PlanResponse;
import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.entity.PlanMember;
import com.patriot.fourlipsclover.plan.repository.PlanMemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;


@Component
@RequiredArgsConstructor
public class PlanMapper {

    public static Plan toEntity(PlanCreateRequest request, Group group) {

        return Plan.builder()
                .group(group)
                .title(request.getTitle())
                .description(request.getDescription())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .createdAt(LocalDateTime.now())
                .treasurer(request.getTreasurerId())
                .build();
    }

    // Plan 엔티티를 PlanListResponse DTO로 변환
    public static PlanListResponse toPlanListResponse(Plan plan) {
        return new PlanListResponse(
                plan.getPlanId(),
                plan.getGroup().getGroupId(),  // groupId 추출
                plan.getTreasurer(),
                plan.getTitle(),
                plan.getDescription(),
                plan.getStartDate(),
                plan.getEndDate(),
                plan.getCreatedAt()
        );
    }

    // Plan 엔티티 리스트를 PlanListResponse DTO 리스트로 변환
    public static List<PlanListResponse> toPlanListResponseList(List<Plan> plans) {
        return plans.stream()
                .map(PlanMapper::toPlanListResponse)
                .collect(Collectors.toList());
    }

    public static PlanResponse toResponse(Plan plan, PlanMemberRepository planMemberRepository) {
        // PlanMemberRepository를 통해 해당 Plan에 속한 PlanMember들의 memberId 조회
        List<Long> memberIds = planMemberRepository.findByPlan_PlanId(plan.getPlanId())
                .stream()
                .map(planMember -> planMember.getMember().getMemberId())  // memberId만 추출
                .toList();

        return new PlanResponse(
                plan.getPlanId(),
                plan.getGroup().getGroupId(),
                plan.getTreasurer(),
                plan.getTitle(),
                plan.getDescription(),
                plan.getStartDate(),
                plan.getEndDate(),
                plan.getCreatedAt(),
                memberIds
        );
    }

    // Plan 엔티티를 PlanDetailResponse DTO로 변환
    public static PlanDetailResponse toPlanDetailResponse(Plan plan, PlanMemberRepository planMemberRepository) {
        // PlanMemberRepository를 사용하여 해당 Plan에 속한 PlanMember들을 조회
        List<PlanMember> planMembers = planMemberRepository.findByPlan_PlanId(plan.getPlanId());

        // PlanMember 리스트를 Member 객체 리스트로 변환
        List<Member> members = planMembers.stream()
                .map(PlanMember::getMember)  // PlanMember를 통해 Member 추출
                .collect(Collectors.toList());

        // PlanDetailResponse 반환
        return new PlanDetailResponse(
                plan.getPlanId(),
                plan.getGroup().getGroupId(),  // groupId 추출
                plan.getTreasurer(),
                plan.getTitle(),
                plan.getDescription(),
                plan.getStartDate(),
                plan.getEndDate(),
                plan.getCreatedAt(),
                members
        );
    }
}
