package com.arwc3.backend.auth;

import com.arwc3.backend.generated.api.AuthApi;
import com.arwc3.backend.generated.model.LoginResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AuthController implements AuthApi {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @Override
    public ResponseEntity<LoginResponse> login() {
        return ResponseEntity.ok(authService.login());
    }
}
