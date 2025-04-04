package com.patriot.fourlipsclover.match.dto.request;

import com.patriot.fourlipsclover.match.entity.GuideRequestForm;
import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.restaurant.entity.Region;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class MatchCreateRequest {

    @NotNull(message = "태그는 필수입니다")
    @Size(min = 1, max = 3, message = "태그는 1-3개 사이여야 합니다")
    private List<Long> tags;

    @NotNull(message = "지역 정보는 필수입니다")
    private Region region;

    @NotNull(message = "가이드 정보는 필수입니다")
    private Member guide;

    @NotNull(message = "가이드 신청서는 필수입니다")
    private GuideRequestForm guideRequestForm;

}
