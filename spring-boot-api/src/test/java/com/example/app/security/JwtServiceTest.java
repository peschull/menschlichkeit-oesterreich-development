package com.example.app.security;

import org.junit.jupiter.api.Test;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

class JwtServiceTest {
    
    @Test
    void issuesAndParsesToken() {
        var svc = new JwtService("01234567890123456789012345678901");
        var t = svc.issue("user@example.com", Map.of("role", "USER"), 10000);
        var claims = svc.parse(t).getBody();
        assertEquals("user@example.com", claims.getSubject());
        assertEquals("USER", claims.get("role"));
    }
}
