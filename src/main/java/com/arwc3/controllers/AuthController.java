package com.arwc3.controllers;

import com.arwc3.generated.api.AuthApi;
import com.arwc3.generated.model.LoginResponseDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class AuthController implements AuthApi {

    @Override
    public ResponseEntity<LoginResponseDTO> login() {
        return null;
    }
}
