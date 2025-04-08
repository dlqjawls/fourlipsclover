package com.patriot.fourlipsclover.group.service;

import com.patriot.fourlipsclover.config.CustomUserDetails;
import com.patriot.fourlipsclover.exception.*;
import com.patriot.fourlipsclover.group.dto.mapper.GroupMapper;
import com.patriot.fourlipsclover.group.dto.request.GroupCreateRequest;
import com.patriot.fourlipsclover.group.dto.request.GroupUpdateRequest;
import com.patriot.fourlipsclover.group.dto.response.GroupDetailResponse;
import com.patriot.fourlipsclover.group.dto.response.GroupResponse;
import com.patriot.fourlipsclover.group.entity.*;
import com.patriot.fourlipsclover.group.repository.GroupInvitationRepository;
import com.patriot.fourlipsclover.group.repository.GroupJoinRequestRepository;
import com.patriot.fourlipsclover.group.repository.GroupMemberRepository;
import com.patriot.fourlipsclover.group.repository.GroupRepository;
import com.patriot.fourlipsclover.match.entity.GuideRequestForm;
import com.patriot.fourlipsclover.match.entity.Match;
import com.patriot.fourlipsclover.match.repository.GuideRequestFormRepository;
import com.patriot.fourlipsclover.match.repository.MatchRepository;
import com.patriot.fourlipsclover.match.repository.MatchTagRepository;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.notification.service.NotificationService;
import com.patriot.fourlipsclover.plan.entity.Plan;
import com.patriot.fourlipsclover.plan.repository.PlanMemberRepository;
import com.patriot.fourlipsclover.plan.repository.PlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class GroupService {

    private final GroupRepository groupRepository;
    private final GroupInvitationRepository groupInvitationRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final NotificationService notificationService;
    private final MemberRepository memberRepository;
    private final GroupJoinRequestRepository groupJoinRequestRepository;
    private final GuideRequestFormRepository guideRequestFormRepository;
    private final PlanRepository planRepository;
    private final PlanMemberRepository planMemberRepository;
    private final MatchRepository matchRepository;
    private final MatchTagRepository matchTagRepository;

    public GroupResponse createGroup(GroupCreateRequest request, Authentication authentication) {
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Member member = userDetails.getMember();

        Group group = GroupMapper.toEntity(request, member);
        Group savedGroup = groupRepository.save(group);

        GroupMember groupMember = new GroupMember();
        GroupMemberId groupMemberId = new GroupMemberId(savedGroup.getGroupId(), member.getMemberId());  // groupId, memberId 설정
        groupMember.setId(groupMemberId);
        groupMember.setGroup(savedGroup);
        groupMember.setMember(member);
        groupMember.setJoinedAt(LocalDateTime.now());

        groupMemberRepository.save(groupMember);

        return GroupMapper.toResponse(savedGroup);
    }

    public String inviteToGroup(Integer groupId, long currentMemberId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

        boolean isMember = groupMemberRepository.existsById(new GroupMemberId(groupId, currentMemberId));
        if (!isMember) {
            throw new NotGroupMemberException("그룹 소속 회원만 초대 기능을 사용할 수 있습니다.");
        }

        String token = UUID.randomUUID().toString();

        GroupInvitation invitation = new GroupInvitation();
        invitation.setGroupId(groupId);
        invitation.setToken(token);
        invitation.setExpiredAt(LocalDateTime.now().plusDays(1));

        groupInvitationRepository.save(invitation);

        return "https://fourlipsclover.duckdns.org/api/group/join-request/" + token;
    }


    public GroupInvitation checkInvitationValidity(String token) {
        GroupInvitation invitation = groupInvitationRepository.findByToken(token)
                .orElseThrow(() -> new GroupNotFoundException("유효하지 않은 초대 링크입니다."));

        if (invitation.getExpiredAt().isBefore(LocalDateTime.now())) {
            throw new InvitationExpiredException("초대 링크가 만료되었습니다.");
        }

        return invitation;
    }

    public void joinGroupViaInvitation(String token, Long memberId) {
        GroupInvitation invitation = checkInvitationValidity(token);

        Group group = groupRepository.findById(invitation.getGroupId())
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + invitation.getGroupId()));

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new MemberNotFoundException("회원이 존재하지 않습니다. id=" + memberId));

        boolean isMember = groupMemberRepository.existsByGroup_GroupIdAndMember_MemberId(group.getGroupId(), memberId);
        if (isMember) {
            throw new AlreadyMemberException("이미 가입된 사용자입니다.");
        }

        Optional<GroupJoinRequest> existingRequest = groupJoinRequestRepository.findByGroup_GroupIdAndMember_MemberIdAndToken(group.getGroupId(), memberId, token);
        if (existingRequest.isPresent() && "PENDING".equals(existingRequest.get().getStatus())) {
            throw new InvitationAlreadyProcessedException("이미 가입 신청이 완료된 사용자입니다.");
        }

        notificationService.sendGroupJoinRequestNotification(group.getGroupId(), group.getMember().getMemberId());

        GroupJoinRequest joinRequest = GroupMapper.toJoinRequest(group, member, token);
        groupJoinRequestRepository.save(joinRequest);
    }

    public void approveOrRejectInvitation(String token, Integer groupId, Long applicantId, boolean accept, String adminComment) {
        GroupJoinRequest joinRequest = groupJoinRequestRepository.findByGroup_GroupIdAndMember_MemberIdAndToken(groupId, applicantId, token)
                .orElseThrow(() -> new GroupNotFoundException("가입 요청을 찾을 수 없습니다."));

        // 가입 요청 상태가 PENDING인지 확인
        if (!"PENDING".equals(joinRequest.getStatus())) {
            throw new InvitationAlreadyProcessedException("이미 처리된 요청입니다.");
        }

        if (accept) {
            // 이미 가입된 사용자 여부 확인: 그룹 멤버 테이블에서 동일 그룹과 신청자 확인
            GroupMember existingMember = groupMemberRepository.findByGroup_GroupIdAndMember_MemberId(groupId, applicantId);
            if (existingMember != null) {
                throw new AlreadyMemberException("이미 가입된 사용자입니다.");
            }

            joinRequest.setStatus("ACCEPTED");

            // 그룹 정보 조회 (joinRequest.getGroup()도 가능)
            Group group = groupRepository.findById(groupId)
                    .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다."));

            // 가입 요청에 등록된 회원(Member)를 그룹 멤버로 등록
            Member applicant = joinRequest.getMember();

            // GroupMemberId 생성: 그룹 ID와 신청자 멤버 ID 설정
            GroupMemberId groupMemberId = new GroupMemberId(group.getGroupId(), applicant.getMemberId());

            // GroupMember 객체 생성 및 필드 설정
            GroupMember groupMember = new GroupMember();
            groupMember.setId(groupMemberId);
            groupMember.setGroup(group);
            groupMember.setMember(applicant);
            groupMember.setJoinedAt(LocalDateTime.now());

            // 그룹 멤버 저장
            groupMemberRepository.save(groupMember);
        } else {
            joinRequest.setStatus("REJECTED");
        }

        joinRequest.setAdminComment(adminComment);
        joinRequest.setUpdatedAt(LocalDateTime.now());
        groupJoinRequestRepository.save(joinRequest);

        // 그룹 생성자(그룹 리더)에게 알림 전송
        Long groupCreatorId = joinRequest.getGroup().getMember().getMemberId();
        notificationService.sendGroupJoinRequestNotification(groupId, groupCreatorId);
    }

    public GroupResponse updateGroup(Integer groupId, GroupUpdateRequest request, Authentication authentication) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Long loggedInMemberId = userDetails.getMember().getMemberId();

        if (!(group.getMember().getMemberId()).equals(loggedInMemberId)) {
            throw new UnauthorizedAccessException("그룹 생성자만 수정할 수 있습니다.");
        }

        GroupMapper.updateEntity(group, request);
        Group updatedGroup = groupRepository.save(group);

        return GroupMapper.toResponse(updatedGroup);
    }

    @Transactional(readOnly = true)
    public List<GroupResponse> getMyGroups(Long loggedInMemberId) {
        // GroupMember를 기준으로 해당 memberId에 속한 그룹을 찾는다.
        List<GroupMember> groupMembers = groupMemberRepository.findByIdMemberId(loggedInMemberId);

        // 그룹 목록을 반환
        return groupMembers.stream()
                .map(groupMember -> GroupMapper.toResponse(groupMember.getGroup()))  // Group 객체로 변환
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public GroupDetailResponse getGroupDetails(Integer groupId, Long loggedInMemberId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

//        boolean isMember = groupMemberRepository.existsByGroup_GroupIdAndMember_MemberId(groupId, loggedInMemberId);
//        if (!isMember) {
//            throw new UnauthorizedAccessException("그룹에 속한 사용자만 접근할 수 있습니다.");
//        }

        List<GroupMember> groupMembers = groupMemberRepository.findByGroup_GroupId(groupId);
        List<Member> members = groupMembers.stream()
                .map(GroupMember::getMember)
                .collect(Collectors.toList());

        return new GroupDetailResponse(group, members);
    }

    public void deleteGroup(int groupId, Long loggedInMemberId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

        if (!(group.getMember().getMemberId()).equals(loggedInMemberId)) {
            throw new UnauthorizedAccessException("그룹 생성자만 수정할 수 있습니다");
        }

        // 그룹과 연관된 Match 및 MatchTag 데이터 삭제
        // guide_request_form을 통해 연결된 Match 리스트를 조회
        List<Match> matches = matchRepository.findByGuideRequestForm_Group_GroupId(groupId);
        // 각 match에 대해 match_tag 테이블의 데이터 삭제
        for (Match match : matches) {
            // matchTagRepository는 match와 연관된 모든 match_tag 데이터를 삭제하는 메서드가 있어야 함
            matchTagRepository.deleteByMatch(match);
        }
        // match 테이블의 데이터 삭제
        for (Match match : matches) {
            matchRepository.delete(match);
        }

        // 그룹과 연관된 GuideRequestForm 삭제
        guideRequestFormRepository.deleteByGroup_GroupId(groupId);

        // 그룹에 속한 Plan 및 PlanMember 삭제
        List<Plan> plans = planRepository.findByGroup_GroupId(groupId);
        for (Plan plan : plans) {
            planMemberRepository.deleteByPlan_PlanId(plan.getPlanId());
        }
        planRepository.deleteByGroup_GroupId(groupId);

        // 그룹 초대(GroupInvitation) 데이터 삭제
        groupInvitationRepository.deleteByGroupId(groupId);

        // 그룹 가입 요청(GroupJoinRequest) 데이터 삭제
        groupJoinRequestRepository.deleteByGroup_GroupId(groupId);

        // 그룹 멤버(GroupMember) 삭제
        groupMemberRepository.deleteByGroup_groupId(groupId);

        groupRepository.delete(group);
    }

    @Transactional(readOnly = true)
    public List<GroupJoinRequest> joinRequestList(Integer groupId, Long memberId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

        if (!group.getMember().getMemberId().equals(memberId)) {
            throw new UnauthorizedAccessException("그룹 생성자만 가입 요청 목록을 확인할 수 있습니다.");
        }

        return groupJoinRequestRepository.findByGroup_GroupId(groupId);
    }

    public void handleGroupAssignment(GuideRequestForm guideRequestForm, long currentMemId) {
        // 그룹이 선택되지 않은 경우 (나홀로 여행 선택)
        if (guideRequestForm.getGroup() == null) {
            Member member = memberRepository.findByMemberId(currentMemId);
            // 새로운 그룹을 생성하고, 해당 그룹에 매칭 신청자 추가
            Group newGroup = new Group();
            newGroup.setName("떠나봐요 " + guideRequestForm.getFoodPreference() + "여행");  // 기본 이름 설정
            newGroup.setDescription(guideRequestForm.getTastePreference() + "떠나는 여행");
            newGroup.setIsPublic(false);
            newGroup.setCreatedAt(LocalDateTime.now());
            newGroup.setMember(member);
            // 그룹 생성 후, 해당 그룹의 ID를 신청서에 설정
            groupRepository.save(newGroup);

            GroupMember groupMember = new GroupMember();
            GroupMemberId groupMemberId = new GroupMemberId(newGroup.getGroupId(), member.getMemberId());
            groupMember.setId(groupMemberId);
            groupMember.setGroup(newGroup);
            groupMember.setMember(member);
            groupMember.setJoinedAt(LocalDateTime.now());

            groupMemberRepository.save(groupMember);

            // 신청서에 생성된 그룹 ID 저장
            guideRequestForm.setGroup(newGroup);
            guideRequestFormRepository.save(guideRequestForm);
        }
    }

}
