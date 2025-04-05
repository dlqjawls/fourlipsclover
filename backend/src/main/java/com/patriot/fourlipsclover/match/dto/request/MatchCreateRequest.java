package com.patriot.fourlipsclover.match.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.util.List;

@Getter
@Setter
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MatchCreateRequest {

    @NotNull(message = "태그는 필수입니다")
    @Size(min = 1, max = 3, message = "태그는 1-3개 사이여야 합니다")
    private List<TagRequest> tags;

    @NotNull(message = "지역 정보는 필수입니다")
    private RegionRequest region;

    @NotNull(message = "가이드 정보는 필수입니다")
    private MemberRequest guide;

    @NotNull(message = "가이드 신청서는 필수입니다")
    private GuideRequestFormRequest guideRequestForm;

}
