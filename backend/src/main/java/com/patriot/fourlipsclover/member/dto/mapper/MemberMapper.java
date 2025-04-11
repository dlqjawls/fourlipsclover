package com.patriot.fourlipsclover.member.dto.mapper;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.plan.dto.request.AddedMemberInfo;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface MemberMapper {

    AddedMemberInfo toAddedMemberInfo(Member member);
}