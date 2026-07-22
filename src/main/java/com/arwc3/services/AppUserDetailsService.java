package com.arwc3.services;

import java.util.List;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AppUserDetailsService implements UserDetailsService {

    @Override
    public UserDetails loadUserByUsername(String username) {
        return new User(
                 username,
                 username,
                 List.of(new SimpleGrantedAuthority("ROLE_USER")));
        // AppUser appUser = appUserRepository.findByUsername(username)
        //         .orElseThrow(() -> new UsernameNotFoundException("Utilisateur inconnu : " + username));

        // return new User(
        //         appUser.getUsername(),
        //         appUser.getPassword(),
        //         List.of(new SimpleGrantedAuthority("ROLE_USER")));
    }
}