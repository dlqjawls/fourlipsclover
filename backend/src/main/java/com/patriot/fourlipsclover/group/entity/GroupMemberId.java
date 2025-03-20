package com.patriot.fourlipsclover.group.entity;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class GroupMemberId implements Serializable {

    private Integer groupId;
    private Integer memberId;

}