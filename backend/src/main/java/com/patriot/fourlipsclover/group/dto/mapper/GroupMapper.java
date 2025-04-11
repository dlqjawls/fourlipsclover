package com.patriot.fourlipsclover.group.dto.mapper;

import com.patriot.fourlipsclover.group.dto.request.GroupCreateRequest;
import com.patriot.fourlipsclover.group.dto.request.GroupUpdateRequest;
import com.patriot.fourlipsclover.group.dto.response.GroupResponse;
import com.patriot.fourlipsclover.group.entity.Group;
import com.patriot.fourlipsclover.group.entity.GroupJoinRequest;
import com.patriot.fourlipsclover.member.entity.Member;

import java.time.LocalDateTime;

public class GroupMapper {

    public static Group toEntity(GroupCreateRequest request, Member member) {
        Group group = new Group();
        group.setName(request.getName());
        group.setDescription(request.getDescription());
        group.setIsPublic(request.getIsPublic());
        group.setMember(member); // 연관관계 설정
        group.setCreatedAt(LocalDateTime.now());
        return group;
    }

    public static void updateEntity(Group group, GroupUpdateRequest request) {
        group.setName(request.getName());
        group.setDescription(request.getDescription());
        if (request.getIsPublic() != null) {
            group.setIsPublic(request.getIsPublic());
        }
        group.setUpdatedAt(LocalDateTime.now());
    }

    public static GroupResponse toResponse(Group group) {
        GroupResponse response = new GroupResponse();
        response.setGroupId(group.getGroupId());
        response.setMemberId(group.getMember() != null ? group.getMember().getMemberId() : null);
        response.setName(group.getName());
        response.setDescription(group.getDescription());
        response.setIsPublic(group.getIsPublic());
        response.setCreatedAt(group.getCreatedAt());
        response.setUpdatedAt(group.getUpdatedAt());
        return response;
    }

    public static GroupJoinRequest toJoinRequest(Group group, Member member, String token) {
        GroupJoinRequest joinRequest = new GroupJoinRequest();
        joinRequest.setGroup(group);
        joinRequest.setMember(member);
        joinRequest.setStatus("PENDING");
        joinRequest.setToken(token);
        joinRequest.setRequestedAt(LocalDateTime.now());
        return joinRequest;
    }

}
