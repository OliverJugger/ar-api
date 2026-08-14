package com.arwc3.services;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.stream.Collectors;

import com.arwc3.config.OracleJdbcProperties;
import com.arwc3.generated.model.CurrentUserDTO;
import com.arwc3.generated.model.LoginResponseDTO;

import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

/**
 * Authentification déléguée à Oracle : on tente d'ouvrir une connexion JDBC
 * avec les identifiants saisis. Si Oracle les accepte, on émet un JWT.
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String TOKEN_TYPE = "Bearer";

    private final JwtService jwtService;
    private final OracleJdbcProperties oracleJdbcProperties;

    /**
     * Vérifie les identifiants auprès d'Oracle et produit un jeton de 15 minutes.
     *
     * @throws BadCredentialsException si Oracle refuse la connexion
     */
    public LoginResponseDTO authenticate(String username, String password) {

        String url = oracleJdbcProperties.getUrlPrefix() + "//"
                + oracleJdbcProperties.getHost() + ":"
                + oracleJdbcProperties.getPort() + "/"
                + oracleJdbcProperties.getService();

        try (Connection connection = DriverManager.getConnection(url, username, password)) {
            CurrentUserDTO user = toCurrentUser(username);
            String token = jwtService.generateToken(user.getUsername(), user.getDisplayName());

            return new LoginResponseDTO(
                    true,
                    token,
                    TOKEN_TYPE,
                    jwtService.getValiditySeconds(),
                    user);

        } catch (SQLException e) {
            throw new BadCredentialsException("Identifiants invalides", e);
        }
    }

    /**
     * Construit le profil affiché à partir du login Oracle.
     *
     * TODO : remplacer par une lecture de la table utilisateurs ARTHUS
     * (nom, prénom, service...) quand elle sera branchée.
     */
    private CurrentUserDTO toCurrentUser(String username) {
        String[] parts = username.split("[._-]");

        String displayName = Arrays.stream(parts)
                .map(part -> part.replaceAll("\\d+$", ""))
                .filter(part -> !part.isEmpty())
                .map(part -> Character.toUpperCase(part.charAt(0)) + part.substring(1).toLowerCase())
                .collect(Collectors.joining(" "));

        String initials = Arrays.stream(parts)
                .filter(part -> !part.isEmpty())
                .limit(2)
                .map(part -> String.valueOf(Character.toUpperCase(part.charAt(0))))
                .collect(Collectors.joining());

        if (displayName.isEmpty()) {
            displayName = username;
        }

        return new CurrentUserDTO(username, displayName).avatarInitials(initials);
    }
}
