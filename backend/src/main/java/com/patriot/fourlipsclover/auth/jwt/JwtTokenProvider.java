package com.patriot.fourlipsclover.auth.jwt;

import com.patriot.fourlipsclover.member.entity.Member;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

@Component
public class JwtTokenProvider {

    @Value("${jwt.secret}")
    private String secretKey;

    @Value("${jwt.validity-in-ms}")
    private long validityInMilliseconds;

    public String generateToken(Member member) {
        Claims claims = Jwts.claims().setSubject(String.valueOf(member.getMemberId()));
        claims.put("email", member.getEmail());
        claims.put("nickname", member.getNickname());

        Date now = new Date();
        Date validity = new Date(now.getTime() + validityInMilliseconds);

        Key key = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));

        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(now)
                .setExpiration(validity)
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

}
