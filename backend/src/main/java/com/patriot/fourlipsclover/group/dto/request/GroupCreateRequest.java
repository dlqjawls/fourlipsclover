package com.patriot.fourlipsclover.group.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GroupCreateRequest {

    @NotBlank(message = "그룹 이름은 필수입니다.")
    @Size(max = 30, message = "그룹 이름은 최대 30자까지 가능합니다.")
    private String name;

    @NotBlank(message = "그룹 설명은 필수입니다.")
    @Size(max = 50, message = "그룹 설명은 최대 50자까지 가능합니다.")
    private String description;

    @NotNull(message = "공개 여부는 필수입니다.")
    private Boolean isPublic;

}
