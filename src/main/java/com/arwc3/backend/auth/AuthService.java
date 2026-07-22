package com.arwc3.backend.auth;

import com.arwc3.backend.generated.model.LoginResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final AppUserRepository appUserRepository;
    private final UserMapper userMapper;

    public AuthService(AppUserRepository appUserRepository, UserMapper userMapper) {
        this.appUserRepository = appUserRepository;
        this.userMapper = userMapper;
    }

    /**
     * L'authentification HTTP Basic est déjà validée par Spring Security avant
     * d'atteindre ce service : on se contente ici de renvoyer le profil de
     * l'utilisateur courant.
     */
    public LoginResponse login() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AppUser appUser = appUserRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new IllegalStateException(
                        "Utilisateur authentifié introuvable : " + authentication.getName()));

        LoginResponse response = new LoginResponse();
        response.setSuccess(true);
        response.setUser(userMapper.toCurrentUser(appUser));
        return response;
    }
}
