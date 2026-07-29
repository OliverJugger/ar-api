package com.arwc3.controllers;

import com.arwc3.generated.api.AuthApi;
import com.arwc3.generated.model.LoginResponseDTO;
import com.arwc3.generated.model.CurrentUserDTO;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;
import com.arwc3.services.AuthService;
import org.springframework.http.ResponseEntity;

@RestController
@RequiredArgsConstructor
public class AuthController implements AuthApi {

    private final AuthService authService;

    @Override
    public ResponseEntity<LoginResponseDTO> login() {
        authService.login();
        return ResponseEntity.ok(new LoginResponseDTO(true, new CurrentUserDTO("omignot", "Olivier Mignot")));
    }
}