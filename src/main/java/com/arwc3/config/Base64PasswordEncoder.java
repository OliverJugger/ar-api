package com.arwc3.security;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Encodeur "simple" en base64, tel que demandé pour ce projet.
 * Attention : le base64 n'est pas un hachage, il est trivialement réversible.
 * Ne pas utiliser tel quel pour un système exposé publiquement.
 */
public class Base64PasswordEncoder implements PasswordEncoder {

    @Override
    public String encode(CharSequence rawPassword) {
        return Base64.getEncoder().encodeToString(rawPassword.toString().getBytes(StandardCharsets.UTF_8));
    }

    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        return encode(rawPassword).equals(encodedPassword);
    }
}
