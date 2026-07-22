package com.arwc3.services;

import com.arwc3.generated.model.LoginResponseDTO;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthService {

    /**
     * L'authentification HTTP Basic est déjà validée par Spring Security avant
     * d'atteindre ce service : on se contente ici de renvoyer le profil de
     * l'utilisateur courant.
     */
    public LoginResponseDTO login() {
        return null;
        // Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        // AppUser appUser = appUserRepository.findByUsername(authentication.getName())
        //         .orElseThrow(() -> new IllegalStateException(
        //                 "Utilisateur authentifié introuvable : " + authentication.getName()));

        // LoginResponse response = new LoginResponse();
        // response.setSuccess(true);
        // response.setUser(userMapper.toCurrentUser(appUser));
        // return response;
    }
}
