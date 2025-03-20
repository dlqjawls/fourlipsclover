package com.patriot.fourlipsclover.group.dto.response;

import com.patriot.fourlipsclover.group.entity.Group;
import com.patriot.fourlipsclover.member.entity.Member;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class GroupDetailResponse {

    private Integer groupId;
    private String name;
    private String description;
    private Boolean isPublic;
    private List<Member> members; // 그룹 소속 멤버 목록

    public GroupDetailResponse(Group group, List<Member> members) {
        this.groupId = group.getGroupId();
        this.name = group.getName();
        this.description = group.getDescription();
        this.isPublic = group.getIsPublic();
        this.members = members;
    }
}