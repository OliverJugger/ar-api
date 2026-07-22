package com.arwc3.backend.auth;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(name = "APP_USER", uniqueConstraints = @UniqueConstraint(columnNames = "USERNAME"))
public class AppUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "USERNAME", nullable = false, length = 100)
    private String username;

    /** Mot de passe encodé en base64 (voir {@link com.arwc3.backend.security.Base64PasswordEncoder}). */
    @Column(name = "PASSWORD", nullable = false, length = 255)
    private String password;

    @Column(name = "DISPLAY_NAME", nullable = false, length = 200)
    private String displayName;

    @Column(name = "AVATAR_INITIALS", length = 10)
    private String avatarInitials;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getAvatarInitials() {
        return avatarInitials;
    }

    public void setAvatarInitials(String avatarInitials) {
        this.avatarInitials = avatarInitials;
    }
}
