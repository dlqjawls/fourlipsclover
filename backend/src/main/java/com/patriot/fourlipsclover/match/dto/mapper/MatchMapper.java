package com.patriot.fourlipsclover.match.dto.mapper;

import com.patriot.fourlipsclover.match.dto.request.GuideRequestFormRequest;
import com.patriot.fourlipsclover.match.entity.GuideRequestForm;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface MatchMapper {

    GuideRequestForm toGuideRequestForm(GuideRequestFormRequest request);
}
