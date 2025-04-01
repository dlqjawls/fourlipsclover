package com.patriot.fourlipsclover.restaurant.service;

import com.patriot.fourlipsclover.restaurant.dto.response.RegionListResponse;
import com.patriot.fourlipsclover.restaurant.entity.Region;
import com.patriot.fourlipsclover.restaurant.repository.RegionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RegionService {

    private final RegionRepository regionRepository;

    // region 전체 목록 조회
    public List<RegionListResponse> getRegionList() {
        List<Region> regions = regionRepository.findAll();

        return regions.stream()
                .map(region -> new RegionListResponse(region.getRegionId(), region.getName()))
                .collect(Collectors.toList());
    }

}
