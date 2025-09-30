package com.example.app.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;
import java.util.Map;

@Service
public class JwtService {
    private final Key key;
    
    public JwtService(@Value("${app.jwt.secret}") String secret) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes());
    }
    
    public String issue(String subject, Map<String, Object> claims, long ttlMs) {
        return Jwts.builder()
            .setSubject(subject)
            .addClaims(claims)
            .setExpiration(new Date(System.currentTimeMillis() + ttlMs))
            .signWith(key)
            .compact();
    }
    
    public Jws<Claims> parse(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(key)
            .build()
            .parseClaimsJws(token);
    }
}
