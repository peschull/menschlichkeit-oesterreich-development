package com.example.app.user.dto;

import java.util.UUID;

public record UserResponse(UUID id, String email, String role) {}
