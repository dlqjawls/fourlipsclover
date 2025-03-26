package com.patriot.fourlipsclover.plan.dto.request;

import com.patriot.fourlipsclover.member.entity.Member;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
public class PlanCreateRequest {

    @NotBlank(message = "계획 이름은 필수입니다.")
    @Size(max = 30, message = "계획 이름은 최대 30자까지 가능합니다.")
    private String title;

    @Size(max = 255, message = "계획 설명은 최대 255자까지 가능합니다.")
    private String description;

    @NotNull(message = "시작 일자 기입은 필수입니다.")
    private LocalDate startDate;
    @NotNull(message = "종료 일자 기입은 필수입니다.")
    private LocalDate endDate;

    @NotNull(message = "계획 생성을 위한 최소 인원은 1명 입니다.")
    private List<Member> members;

    @NotNull(message = "총무는 필수 설정입니다.")
    private Long treasurerId;

}
