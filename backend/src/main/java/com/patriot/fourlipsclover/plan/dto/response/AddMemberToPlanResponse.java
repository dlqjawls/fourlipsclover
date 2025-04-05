package com.patriot.fourlipsclover.plan.dto.response;

import com.patriot.fourlipsclover.plan.dto.request.AddedMemberInfo;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AddMemberToPlanResponse {

    private List<AddedMemberInfo> addedMembers;

}
