package com.arwc3.services;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.Map;

/**
 * Génération et validation des jetons JWT (HS256).
 *
 * <p>La clé de signature et la durée de validité sont externalisées dans
 * application.yml sous {@code arthus.security.jwt.*}. La clé doit faire au
 * moins 32 octets (256 bits) pour HS256 — sinon jjwt lève une
 * WeakKeyException au démarrage.</p>
 */
@Service
public class JwtService {

    private static final Logger log = LoggerFactory.getLogger(JwtService.class);

    private final SecretKey signingKey;
    private final Duration validity;

    public JwtService(
            @Value("${arthus.security.jwt.secret}") String secret,
            @Value("${arthus.security.jwt.validity:PT15M}") Duration validity) {
        this.signingKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.validity = validity;
    }

    /**
     * Génère un jeton signé pour l'utilisateur donné.
     *
     * @param username    identifiant technique, placé dans le claim {@code sub}
     * @param displayName libellé affichable, placé dans un claim custom
     * @return le jeton compacté (header.payload.signature)
     */
    public String generateToken(String username, String displayName) {
        Instant now = Instant.now();
        Instant expiration = now.plus(validity);

        return Jwts.builder()
                .subject(username)
                .claims(Map.of("displayName", displayName))
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiration))
                .signWith(signingKey)
                .compact();
    }

    /**
     * Valide la signature et l'expiration, puis retourne les claims.
     *
     * @return les claims, ou {@code null} si le jeton est invalide ou expiré
     */
    public Claims parseToken(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(signingKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (JwtException | IllegalArgumentException e) {
            log.debug("Jeton JWT rejeté : {}", e.getMessage());
            return null;
        }
    }

    /** Durée de validité configurée, exposée pour le champ {@code expiresIn} de la réponse. */
    public long getValiditySeconds() {
        return validity.toSeconds();
    }
}
