package com.patriot.fourlipsclover.auth.service;

import com.patriot.fourlipsclover.exception.UserNotFoundException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

@Service
public class KakaoAuthService {

    @Value("${kakao.userinfo.url}")
    private String kakaoUserInfoUrl;

    public String getUserInfo(String accessToken) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    kakaoUserInfoUrl, HttpMethod.GET, entity, String.class);
            return response.getBody();
        } catch (HttpClientErrorException ex) {
            if (ex.getStatusCode() == HttpStatus.UNAUTHORIZED) {
                throw new UserNotFoundException("유효하지 않은 토큰입니다", ex);
            }
            throw ex;
        }
    }

}