package com.patriot.fourlipsclover.auth.controller;

import com.patriot.fourlipsclover.auth.dto.response.JwtResponse;
import com.patriot.fourlipsclover.member.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth/kakao")
public class KakaoAuthController {

    private final MemberService memberService;

    @PostMapping("/login")
    public ResponseEntity<?> kakaoLogin(@RequestBody Map<String, String> body) {
        String accessToken = body.get("accessToken");
        JwtResponse jwtResponse = memberService.processKakaoLoginAndGetToken(accessToken);
        return ResponseEntity.ok(jwtResponse);
    }

}