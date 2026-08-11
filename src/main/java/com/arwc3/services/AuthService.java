package com.arwc3.services;

import com.arwc3.config.OracleJdbcProperties;
import com.arwc3.generated.model.LoginResponseDTO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final OracleJdbcProperties oracleJdbcProperties;

    /**
     * L'authentification HTTP Basic est déjà validée par Spring Security avant
     * d'atteindre ce service : on se contente ici de renvoyer le profil de
     * l'utilisateur courant.
     */
    public LoginResponseDTO login() {
        // Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        // AppUser appUser = appUserRepository.findByUsername(authentication.getName())
        //         .orElseThrow(() -> new IllegalStateException(
        //                 "Utilisateur authentifié introuvable : " + authentication.getName()));

        // LoginResponse response = new LoginResponse();
        // response.setSuccess(true);
        // response.setUser(userMapper.toCurrentUser(appUser));
        // return response;
        
        boolean test1 = this.authenticate("arthus", "iFUo9z6MpKRt7YCk_4No");
        System.out.println(test1);
        boolean test2 = this.authenticate("REC_ADM", "Arthus!12345678");
        System.out.println(test2);
        return null;
    }

    public boolean authenticate (String username, String password) {
        String url = oracleJdbcProperties.getUrlPrefix() + "//"
            + oracleJdbcProperties.getHost() + ":"
            + oracleJdbcProperties.getPort() + "/"
            + oracleJdbcProperties.getBase();

        System.out.println(url);
        try (Connection conn = DriverManager.getConnection(url, username, password)) {
            return true;
        } catch(SQLException e) {
            return false;
            // if(e.getErrorCode() == 1017) {
            //     return false;
            // }
            // throw new RuntimeException("Erreur de connexion à la base Oracle", e);
        }

    }
}
