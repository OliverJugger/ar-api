package com.arwc3.controllers;

import com.arwc3.generated.api.AuthApi;
import com.arwc3.generated.model.LoginRequestDTO;
import com.arwc3.generated.model.LoginResponseDTO;
import com.arwc3.services.AuthService;

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
