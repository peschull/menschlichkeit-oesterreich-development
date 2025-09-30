package com.example.app.user;

import com.example.app.security.JwtService;
import com.example.app.user.dto.*;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final UserRepository users;
    private final JwtService jwt;
    
    public AuthController(UserRepository users, JwtService jwt) {
        this.users = users;
        this.jwt = jwt;
    }
    
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest req) {
        if (users.existsByEmail(req.email())) {
            return ResponseEntity.status(409).body(Map.of("error", "EMAIL_TAKEN"));
        }
        
        var u = new User();
        u.setEmail(req.email());
        u.setPasswordHash(BCrypt.hashpw(req.password(), BCrypt.gensalt()));
        users.save(u);
        
        return ResponseEntity.ok(new UserResponse(u.getId(), u.getEmail(), u.getRole().name()));
    }
    
    public record LoginRequest(String email, String password) {}
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req) {
        var u = users.findByEmail(req.email()).orElse(null);
        
        if (u == null || !BCrypt.checkpw(req.password(), u.getPasswordHash())) {
            return ResponseEntity.status(401).body(Map.of("error", "INVALID_CREDENTIALS"));
        }
        
        var token = jwt.issue(u.getEmail(), Map.of("role", u.getRole().name()), 1000L * 60 * 60 * 12);
        return ResponseEntity.ok(Map.of("accessToken", token));
    }
}
