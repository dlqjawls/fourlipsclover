package com.patriot.fourlipsclover.plan.service;

import com.patriot.fourlipsclover.exception.*;
import com.patriot.fourlipsclover.group.entity.Group;
import com.patriot.fourlipsclover.group.entity.GroupMember;
import com.patriot.fourlipsclover.group.entity.GroupMemberId;
import com.patriot.fourlipsclover.group.repository.GroupMemberRepository;
import com.patriot.fourlipsclover.group.repository.GroupRepository;
import com.patriot.fourlipsclover.member.dto.mapper.MemberMapper;
import com.patriot.fourlipsclover.member.dto.response.MemberInfoResponse;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.plan.dto.mapper.PlanMapper;
import com.patriot.fourlipsclover.plan.dto.request.*;
import com.patriot.fourlipsclover.plan.dto.response.*;
import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.entity.PlanMember;
import com.patriot.fourlipsclover.plan.entity.PlanMemberId;
import com.patriot.fourlipsclover.plan.entity.PlanSchedule;
import com.patriot.fourlipsclover.plan.repository.PlanMemberRepository;
import com.patriot.fourlipsclover.plan.repository.PlanRepository;
import com.patriot.fourlipsclover.plan.repository.PlanScheduleRepository;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class PlanService {

    private final PlanRepository planRepository;
    private final GroupRepository groupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final PlanMemberRepository planMemberRepository;
    private final PlanScheduleRepository planScheduleRepository;
    private final RestaurantJpaRepository restaurantJpaRepository;
    private final MemberMapper memberMapper;

    public PlanResponse createPlan(int groupId, PlanCreateRequest request, long currentMemberId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

        boolean isMember = groupMemberRepository.existsByGroup_GroupIdAndMember_MemberId(groupId, currentMemberId);
        if (!isMember) {
            throw new NotGroupMemberException("그룹 소속 회원만 계획을 생성할 수 있습니다.");
        }

        Plan plan = PlanMapper.toEntity(request, group);

        // 요청에서 전달된 총무가 있으면 해당 값 사용, 없으면 현재 로그인한 사용자를 총무로 설정
        if (request.getTreasurerId() != null) {
            plan.setTreasurer(request.getTreasurerId());
        } else {
            plan.setTreasurer(currentMemberId);
        }

        Plan savedPlan = planRepository.save(plan);

        List<Member> members = request.getMembers();

        for (Member memId : members) {
            boolean isGroupMember = groupMemberRepository.existsByGroup_GroupIdAndMember_MemberId(groupId, memId.getMemberId());
            if (!isGroupMember) {
                throw new NotGroupMemberException("회원 " + memId + "는 그룹 소속 인원이 아닙니다.");
            }

            // 동일 계획에 이미 등록되었는지 확인
            boolean alreadyAdded = planMemberRepository.existsByPlan_PlanIdAndMember_MemberId(savedPlan.getPlanId(), memId.getMemberId());
            if (alreadyAdded) {
//                throw new AlreadyMemberException("회원" + memId + "는 이미 계획에 포함된 인원입니다.");
                continue;
            }

            // 역할 설정: 만약 해당 회원이 총무로 설정된 회원이면 "Treasurer", 아니면 "Participant"
            String role = memId.getMemberId().equals(plan.getTreasurer()) ? "Treasurer" : "Participant";

            // PlanMemberId 및 PlanMember 생성
            PlanMemberId planMemberId = new PlanMemberId(savedPlan.getPlanId(), memId.getMemberId());
            PlanMember planMember = PlanMember.builder()
                    .id(planMemberId)
                    .plan(savedPlan)
                    .member(memId)
                    .role(role)
                    .joinedAt(LocalDateTime.now())
                    .build();

            planMemberRepository.save(planMember);
        }

        return PlanMapper.toResponse(savedPlan, planMemberRepository);
    }

    @Transactional(readOnly = true)
    public List<PlanListResponse> getPlansByGroup(int groupId, long currentMemberId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

        boolean isMember = groupMemberRepository.existsById(new GroupMemberId(groupId, currentMemberId));
        if (!isMember) {
            throw new NotGroupMemberException("그룹 소속 회원만 계획을 확인할 수 있습니다.");
        }

        List<Plan> plans = planRepository.findPlansByGroupId(groupId);
        return PlanMapper.toPlanListResponseList(plans);
    }

    // 특정 계획 조회
    @Transactional(readOnly = true)
    public PlanDetailResponse getPlanById(int planId, int groupId, long currentMemberId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new PlanNotFoundException("계획을 찾을 수 없습니다. id=" + planId));

        boolean isMember = groupMemberRepository.existsByGroup_GroupIdAndMember_MemberId(groupId, currentMemberId);
        if (!isMember) {
            throw new NotGroupMemberException("그룹 소속 회원만 계획을 확인할 수 있습니다.");
        }

        return PlanMapper.toPlanDetailResponse(plan, planMemberRepository);
    }

    // 계획 수정
    public PlanResponse updatePlan(int groupId, int planId, PlanUpdateRequest request, long currentMemberId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new PlanNotFoundException("계획을 찾을 수 없습니다. id=" + planId));

        boolean isMember = groupMemberRepository.existsByGroup_GroupIdAndMember_MemberId(groupId, currentMemberId);
        if (!isMember) {
            throw new NotGroupMemberException("그룹 소속 회원만 계획을 수정할 수 있습니다.");
        }

        plan.setTitle(request.getTitle());
        System.out.println(request.getTitle());

        plan.setDescription(request.getDescription());
        plan.setStartDate(request.getStartDate());
        plan.setEndDate(request.getEndDate());
        plan.setUpdatedAt(LocalDateTime.now());

        planRepository.save(plan);

        return PlanMapper.toResponse(plan, planMemberRepository);
    }

    // 계획 삭제
    public void deletePlan(int groupId, int planId, long currentMemberId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new PlanNotFoundException("계획을 찾을 수 없습니다. id=" + planId));

        boolean isMember = groupMemberRepository.existsByGroup_GroupIdAndMember_MemberId(groupId, currentMemberId);
        if (!isMember) {
            throw new NotGroupMemberException("그룹 소속 회원만 계획을 삭제할 수 있습니다.");
        }

        planMemberRepository.deleteByPlan_PlanId(planId);
        planRepository.delete(plan);
    }

    // 일정 생성
    public PlanSchedule createPlanSchedule(int planId, PlanScheduleCreateRequest request, long currentMemberId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new PlanNotFoundException("계획을 찾을 수 없습니다. id=" + planId));

        boolean isMember = planMemberRepository.existsByPlan_PlanIdAndMember_MemberId(planId, currentMemberId);
        if (!isMember) {
            throw new NotGroupMemberException("계획에 참여한 회원만 일정을 추가할 수 있습니다.");
        }

        Restaurant restaurant = restaurantJpaRepository.findByRestaurantId(request.getRestaurantId());

        PlanSchedule planSchedule = new PlanSchedule();
        planSchedule.setPlan(plan);
        planSchedule.setRestaurant(restaurant);
        planSchedule.setNotes(request.getNotes());
        planSchedule.setVisitAt(request.getVisitAt());
        planSchedule.setCreatedAt(LocalDateTime.now());

        // ResponseEntity 생성
        return planScheduleRepository.save(planSchedule);
    }

    // 일정 목록 조회
    public List<PlanScheduleResponse> getPlanSchedules(int planId, long currentMemberId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new PlanNotFoundException("계획을 찾을 수 없습니다. id=" + planId));

        boolean isMember = planMemberRepository.existsByPlan_PlanIdAndMember_MemberId(planId, currentMemberId);
        if (!isMember) {
            throw new NotGroupMemberException("계획에 참여한 회원만 일정을 조회할 수 있습니다.");
        }

        List<PlanSchedule> schedules = planScheduleRepository.findByPlan(plan);

        return schedules.stream()
                .map(schedule -> new PlanScheduleResponse(
                        schedule.getPlanScheduleId(),
                        schedule.getRestaurant().getPlaceName(),
                        schedule.getNotes(),
                        schedule.getVisitAt()
                ))
                .collect(Collectors.toList());
    }

    // 특정 일정 조회
    public PlanScheduleDetailResponse getPlanSchedule(int scheduleId, long currentMemberId) {
        PlanSchedule schedule = planScheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new PlanNotFoundException("일정을 찾을 수 없습니다. id=" + scheduleId));

        Plan plan = schedule.getPlan();
        boolean isMember = planMemberRepository.existsByPlan_PlanIdAndMember_MemberId(plan.getPlanId(), currentMemberId);
        if (!isMember) {
            throw new NotGroupMemberException("계획에 참여한 회원만 일정을 조회할 수 있습니다.");
        }

        PlanScheduleDetailResponse response = new PlanScheduleDetailResponse();
        response.setPlanId(plan.getPlanId());
        response.setPlanScheduleId(scheduleId);
        response.setNotes(schedule.getNotes());
        response.setVisitAt(schedule.getVisitAt());
        response.setUpdatedAt(schedule.getUpdatedAt());
        response.setRestaurant(schedule.getRestaurant());

        return response;
    }

    // 일정 수정
    public PlanScheduleUpdateResponse updatePlanSchedule(int scheduleId, PlanScheduleUpdateRequest request, long currentMemberId) {
        PlanSchedule schedule = planScheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new PlanNotFoundException("일정을 찾을 수 없습니다. id=" + scheduleId));

        Plan plan = schedule.getPlan();
        boolean isMember = planMemberRepository.existsByPlan_PlanIdAndMember_MemberId(plan.getPlanId(), currentMemberId);
        if (!isMember) {
            throw new NotGroupMemberException("계획에 참여한 회원만 일정을 수정할 수 있습니다.");
        }

        boolean isRestaurant = restaurantJpaRepository.existsByRestaurantId(request.getRestaurantId());
        if (!isRestaurant) {
            throw new RestaurantNotFoundException("식당이 존재하지 않습니다.");
        }
        Restaurant newRestaurant = restaurantJpaRepository.findByRestaurantId(request.getRestaurantId());

        schedule.setRestaurant(newRestaurant);
        schedule.setNotes(request.getNotes());
        schedule.setVisitAt(request.getVisitAt());

        planScheduleRepository.save(schedule);

        PlanScheduleUpdateResponse response = new PlanScheduleUpdateResponse();
        response.setRestaurant(newRestaurant);
        response.setPlaceName(schedule.getRestaurant().getPlaceName());
        response.setNotes(schedule.getNotes());
        response.setVisitAt(schedule.getVisitAt());

        return response;
    }

    // 일정 삭제
    public void deletePlanSchedule(int scheduleId, long currentMemberId) {
        PlanSchedule schedule = planScheduleRepository.findById(scheduleId)
                .orElseThrow(() -> new PlanNotFoundException("일정을 찾을 수 없습니다. id=" + scheduleId));

        Plan plan = schedule.getPlan();
        boolean isMember = planMemberRepository.existsByPlan_PlanIdAndMember_MemberId(plan.getPlanId(), currentMemberId);
        if (!isMember) {
            throw new NotPlanMemberException("계획에 참여한 회원만 일정을 삭제할 수 있습니다.");
        }

        planScheduleRepository.delete(schedule);
    }

    // plan이 소속된 group의 인원 중 현재 plan에 소속되지 않은 member list 조회
    public List<MemberInfoResponse> getAvailableMemberInfo(Integer groupId, Integer planId, long currentMemberId) {
        // 현재 요청자가 해당 Plan의 구성원인지 확인 (권한 체크)
        if (!planMemberRepository.existsByPlan_PlanIdAndMember_MemberId(planId, currentMemberId)) {
            throw new NotPlanMemberException("계획에 참여한 회원만 이용할 수 있습니다.");
        }

        // Plan에 이미 포함된 회원 ID 집합 생성
        Set<Long> planMemberIds = planMemberRepository.findByPlan_PlanId(planId)
                .stream()
                .map(pm -> pm.getMember().getMemberId())
                .collect(Collectors.toSet());

        // 그룹에 소속된 모든 멤버 중, Plan에 포함되지 않은 회원들을 조회 후 DTO로 매핑
        return groupMemberRepository.findByGroup_GroupId(groupId)
                .stream()
                .map(GroupMember::getMember)
                .filter(member -> !planMemberIds.contains(member.getMemberId()))
                .map(member -> new MemberInfoResponse(
                        member.getMemberId(),
                        member.getNickname(),
                        member.getEmail()))
                .collect(Collectors.toList());
    }

    // plan이 소속된 group에서 인원 추가
    public AddMemberToPlanResponse addMemberToPlan(Integer planId, Integer groupId, long currentMemberId, List<AddMemberToPlanRequest> requests) {
        if (!planMemberRepository.existsByPlan_PlanIdAndMember_MemberId(planId, currentMemberId)) {
            throw new NotPlanMemberException("계획에 참여한 회원만 친구 초대 기능을 사용할 수 있습니다.");
        }
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new PlanNotFoundException("계획을 찾을 수 없습니다. id=" + planId));
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

        // 그룹 멤버들 조회, Map 구성 (memberId -> Member)
        List<GroupMember> groupMembers = groupMemberRepository.findByGroup_GroupId(groupId);
        Map<Long, Member> groupMemberMap = groupMembers.stream()
                .collect(Collectors.toMap(gm -> gm.getMember().getMemberId(), GroupMember::getMember));

        List<AddedMemberInfo> addedMembers = new ArrayList<>();

        // 요청으로 넘어온 각 memberId에 대해 처리
        for (AddMemberToPlanRequest req : requests) {
            Long memberId = req.getMemberId();

            // 그룹에 속한 멤버인지 확인 (이미 조회한 Map 사용)
            Member member = groupMemberMap.get(memberId);
            if (member == null) {
                throw new NotGroupMemberException("그룹에 속하지 않은 멤버입니다. memberId: " + memberId);
            }
            // 해당 멤버가 이미 계획에 소속되어 있는지 확인
            if (planMemberRepository.existsByPlan_PlanIdAndMember_MemberId(planId, memberId)) {
                throw new AlreadyMemberException("이미 계획에 소속된 멤버입니다. memberId: " + memberId);
            }

            // PlanMember 엔티티 생성 및 저장 (역할은 "Participant", 가입 시각은 현재 시간)
            PlanMemberId planMemberId = new PlanMemberId(plan.getPlanId(), memberId);
            PlanMember planMember = PlanMember.builder()
                    .id(planMemberId)
                    .plan(plan)
                    .member(member)
                    .role("Participant")
                    .joinedAt(LocalDateTime.now())
                    .build();
            planMemberRepository.save(planMember);

            // 추가된 회원의 정보를 AddedMemberInfo에 저장
            addedMembers.add(memberMapper.toAddedMemberInfo(member));
        }

        return new AddMemberToPlanResponse(addedMembers);
    }

    @Transactional
    public void leavePlan(Integer planId, long currentMemberId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("계획을 찾을 수 없습니다. id=" + planId));

        PlanMember planMember = (PlanMember) planMemberRepository.findByPlan_PlanIdAndMember_MemberId(planId, currentMemberId)
                .orElseThrow(() -> new NotPlanMemberException("해당 계획에 소속되어 있지 않습니다."));

        planMemberRepository.delete(planMember);
    }
}
