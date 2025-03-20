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
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.member.repository.MemberRepository;
import com.patriot.fourlipsclover.notification.service.NotificationService;
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

    public String inviteToGroup(Integer groupId, Integer currentMemberId) {
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

        return "http://localhost:8080/api/group/join-request/" + token;
    }


    public GroupInvitation checkInvitationValidity(String token) {
        GroupInvitation invitation = groupInvitationRepository.findByToken(token)
                .orElseThrow(() -> new GroupNotFoundException("유효하지 않은 초대 링크입니다."));

        if (invitation.getExpiredAt().isBefore(LocalDateTime.now())) {
            throw new InvitationExpiredException("초대 링크가 만료되었습니다.");
        }

        return invitation;
    }

    public void joinGroupViaInvitation(String token, Integer memberId) {
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

    public void approveOrRejectInvitation(String token, Integer groupId, Integer applicantId, boolean accept, String adminComment) {
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
        Integer groupCreatorId = joinRequest.getGroup().getMember().getMemberId();
        notificationService.sendGroupJoinRequestNotification(groupId, groupCreatorId);
    }

    public GroupResponse updateGroup(Integer groupId, GroupUpdateRequest request, Authentication authentication) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Integer loggedInMemberId = userDetails.getMember().getMemberId();

        if (!Integer.valueOf(group.getMember().getMemberId()).equals(loggedInMemberId)) {
            throw new UnauthorizedAccessException("그룹 생성자만 수정할 수 있습니다.");
        }

        GroupMapper.updateEntity(group, request);
        Group updatedGroup = groupRepository.save(group);

        return GroupMapper.toResponse(updatedGroup);
    }

    @Transactional(readOnly = true)
    public List<GroupResponse> getMyGroups(Integer loggedInMemberId) {
        List<Group> groups = groupRepository.findByMemberMemberId(loggedInMemberId);
        return groups.stream()
                .map(GroupMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public GroupDetailResponse getGroupDetails(Integer groupId, Integer loggedInMemberId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

        List<GroupMember> groupMembers = groupMemberRepository.findByGroup_GroupId(groupId);

        List<Member> members = groupMembers.stream()
                .map(GroupMember::getMember)
                .collect(Collectors.toList());

        return new GroupDetailResponse(group, members);
    }

    public void deleteGroup(int groupId, Integer loggedInMemberId) {
        Group group = groupRepository.findById(groupId)
                .orElseThrow(() -> new GroupNotFoundException("그룹을 찾을 수 없습니다. id=" + groupId));

        if (!Integer.valueOf(group.getMember().getMemberId()).equals(loggedInMemberId)) {
            throw new UnauthorizedAccessException("그룹 생성자만 수정할 수 있습니다");
        }

        groupMemberRepository.deleteByGroup_groupId(groupId);
        groupRepository.deleteById(loggedInMemberId);
    }

}
