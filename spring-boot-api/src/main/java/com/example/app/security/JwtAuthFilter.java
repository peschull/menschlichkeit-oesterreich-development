package com.example.app.security;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.List;

@Component
public class JwtAuthFilter extends GenericFilter {
    private final JwtService jwtService;
    
    public JwtAuthFilter(JwtService jwtService) {
        this.jwtService = jwtService;
    }
    
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletRequest r = (HttpServletRequest) req;
        String hdr = r.getHeader("Authorization");
        
        if (hdr != null && hdr.startsWith("Bearer ")) {
            try {
                var claims = jwtService.parse(hdr.substring(7)).getBody();
                var auth = new UsernamePasswordAuthenticationToken(
                    claims.getSubject(), 
                    null, 
                    List.of()
                );
                SecurityContextHolder.getContext().setAuthentication(auth);
            } catch (Exception ignored) {
                // Invalid token, continue without authentication
            }
        }
        
        chain.doFilter(req, res);
    }
}
