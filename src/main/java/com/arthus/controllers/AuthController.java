package com.arthus.controllers;

import com.arthus.generated.api.AuthApi;
import com.arthus.generated.model.LoginRequestDTO;
import com.arthus.generated.model.LoginResponseDTO;
import com.arthus.auth.AuthService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class AuthController implements AuthApi {

    private final AuthService authService;

    @Override
    public ResponseEntity<LoginResponseDTO> login(LoginRequestDTO loginRequestDTO) {
        return ResponseEntity.ok(
                authService.authenticate(loginRequestDTO.getUsername(), loginRequestDTO.getPassword()));
    }
}
