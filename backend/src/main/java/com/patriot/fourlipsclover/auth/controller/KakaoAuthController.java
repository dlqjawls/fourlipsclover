package com.patriot.fourlipsclover.auth.controller;

import com.patriot.fourlipsclover.auth.dto.response.JwtResponse;
import com.patriot.fourlipsclover.member.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth/kakao")
public class KakaoAuthController {

    private final MemberService memberService;

    @PostMapping("/login")
    public ResponseEntity<?> kakaoLogin(@RequestHeader("Authorization") String authorizationHeader) {
        String accessToken = authorizationHeader.replace("Bearer ", "");
        JwtResponse jwtResponse = memberService.processKakaoLoginAndGetToken(accessToken);
        return ResponseEntity.ok(jwtResponse);
    }

}