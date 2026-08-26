package com.arthus.auth;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.stream.Collectors;

import com.arthus.entitys.Utilisateur;
import com.arthus.entitys.HistoriqueConnexionUtilisateur;
import com.arthus.entitys.HistoriqueConnexionUtilisateurId;
import com.arthus.repositories.HistoriqueConnexionUtilisateurRepository;
import com.arthus.repositories.UtilisateurRepository;
import com.arthus.config.OracleJdbcProperties;
import com.arthus.generated.model.CurrentUserDTO;
import com.arthus.generated.model.LoginResponseDTO;

import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;
import java.time.LocalDateTime;

/*
 * Authentification déléguée à Oracle : on tente d'ouvrir une connexion JDBC
 * avec les identifiants saisis. Si Oracle les accepte, on émet un JWT.
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String TOKEN_TYPE = "Bearer";
	private static final String ERREUR_IDENTIFIANTS = "Identifiants invalides";

    private final JwtService jwtService;
    private final OracleJdbcProperties oracleJdbcProperties;
    private final UtilisateurRepository utilisateurRepository;
    private final HistoriqueConnexionUtilisateurRepository historiqueConnexionUtilisateurRepository;

    public LoginResponseDTO authenticate(String username, String password) {

        String url = oracleJdbcProperties.getUrlPrefix() + "//"
                + oracleJdbcProperties.getHost() + ":"
                + oracleJdbcProperties.getPort() + "/"
                + oracleJdbcProperties.getService();

        try (Connection connection = DriverManager.getConnection(url, username, password)) {
            CurrentUserDTO user = getCurrentUser(username);
            String token = jwtService.generateToken(user.getUsername(), user.getDisplayName());

			HistoriqueConnexionUtilisateur historique = new HistoriqueConnexionUtilisateur(
				new HistoriqueConnexionUtilisateurId(username, LocalDateTime.now()));
			
			historiqueConnexionUtilisateurRepository.save(historique);

            return new LoginResponseDTO(
                    true,
                    token,
                    TOKEN_TYPE,
                    jwtService.getValiditySeconds(),
                    user);

        } catch (Exception e) {
            throw new BadCredentialsException(ERREUR_IDENTIFIANTS, e);
        }
    }

    private CurrentUserDTO getCurrentUser(String username) {
		Utilisateur currentUser = utilisateurRepository.findByNomIgnoreCase(username)
			.orElseThrow(() -> {
				return new BadCredentialsException(ERREUR_IDENTIFIANTS);
			});
		
        String[] parts = username.split("[._-]");
        String displayName = currentUser.getPseudo();
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
