package com.patriot.fourlipsclover.group.controller;

import com.patriot.fourlipsclover.config.CustomUserDetails;
import com.patriot.fourlipsclover.group.dto.request.GroupCreateRequest;
import com.patriot.fourlipsclover.group.dto.request.GroupUpdateRequest;
import com.patriot.fourlipsclover.group.dto.response.GroupDetailResponse;
import com.patriot.fourlipsclover.group.dto.response.GroupInvitationResponse;
import com.patriot.fourlipsclover.group.dto.response.GroupResponse;
import com.patriot.fourlipsclover.group.entity.GroupInvitation;
import com.patriot.fourlipsclover.group.service.GroupService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/group")
public class GroupController {

    private final GroupService groupService;

    // 그룹 생성
    @PostMapping
    public ResponseEntity<GroupResponse> createGroup(@RequestBody GroupCreateRequest request,
                                                     Authentication authentication) {
        GroupResponse createdGroup = groupService.createGroup(request, authentication);
        return new ResponseEntity<>(createdGroup, HttpStatus.CREATED);
    }

    // 그룹원 - 그룹 초대: 초대 URL 생성하여 및 반환
    @PostMapping("/invitations/{groupId}")
    public ResponseEntity<Map<String, String>> inviteToGroup(@PathVariable Integer groupId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Integer currentMemberId = userDetails.getMember().getMemberId();

        String invitationUrl = groupService.inviteToGroup(groupId, currentMemberId);
        Map<String, String> response = new HashMap<>();
        response.put("invitationUrl", invitationUrl);
        return ResponseEntity.ok(response);
    }

    // 사용자 - 초대 링크 유효 확인
    @GetMapping("/join-request/{token}")
    public ResponseEntity<Map<String, Object>> checkInvitationStatus(@PathVariable String token) {
        // 초대 링크 유효성 검사
        GroupInvitation groupInvitation = groupService.checkInvitationValidity(token);

        // 리디렉션 URL 생성
        String redirectUrl = "https://fourlipsclover.duckdns.org/api/group/join-request/" + token;

        // 결과를 Map으로 생성
        Map<String, Object> response = new HashMap<>();
        response.put("groupInvitation", groupInvitation);  // 초대 정보
        response.put("redirectUrl", redirectUrl);  // 리디렉션 URL

        return ResponseEntity.ok(response);
    }

    // 사용자 - 초대 URL에 접근 후 가입신청
    @PostMapping("/join-request/{token}")
    public ResponseEntity<Void> joinRequest(@PathVariable String token) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Integer memberId = userDetails.getMember().getMemberId();

        groupService.joinGroupViaInvitation(token, memberId);
        return ResponseEntity.ok().build();
    }

    // 그룹생성자 - 가입요청 목록 확인

    // 그룹생성자 - 가입요청 승인/거절
    @PostMapping("/{groupId}/invitations/response/{token}")
    public ResponseEntity<Void> approveOrRejectInvitation(@PathVariable Integer groupId,
                                                          @PathVariable String token,
                                                          @RequestParam boolean accept,
                                                          @RequestParam Integer applicantId,
                                                          @RequestBody GroupInvitationResponse invitationResponse) {
        String adminComment = invitationResponse.getAdminComment();
        System.out.println(adminComment);
        groupService.approveOrRejectInvitation(token, groupId, applicantId, accept, adminComment);
        return ResponseEntity.ok().build();
    }

    // 그룹 수정
    @PutMapping("/{groupId}")
    public ResponseEntity<GroupResponse> updateGroup(@PathVariable Integer groupId,
                                                     @RequestBody GroupUpdateRequest updateRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        GroupResponse updatedGroup = groupService.updateGroup(groupId, updateRequest, authentication);
        return ResponseEntity.ok(updatedGroup);
    }

    // 내 그룹 목록 조회
    @GetMapping("/my-groups")
    public ResponseEntity<List<GroupResponse>> getMyGroups() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Integer loggedInMemberId = userDetails.getMember().getMemberId();
        System.out.println(loggedInMemberId);

        List<GroupResponse> groups = groupService.getMyGroups(loggedInMemberId);
        return ResponseEntity.ok(groups);
    }

    // 내가 속한 그룹정보 및 그룹원 조회
    @GetMapping("/group-detail/{groupId}")
    public ResponseEntity<GroupDetailResponse> getGroupDetails(@PathVariable Integer groupId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Integer loggedInMemberId = userDetails.getMember().getMemberId();

        GroupDetailResponse groupDetails = groupService.getGroupDetails(groupId, loggedInMemberId);
        return ResponseEntity.ok(groupDetails);
    }

    // 그룹 삭제
    @DeleteMapping("/{groupId}")
    public ResponseEntity<Void> deleteGroup(@PathVariable int groupId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Integer loggedInMemberId = userDetails.getMember().getMemberId();

        groupService.deleteGroup(groupId, loggedInMemberId);
        return ResponseEntity.noContent().build();
    }

}