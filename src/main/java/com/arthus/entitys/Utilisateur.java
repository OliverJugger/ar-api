package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

import com.arthus.entitys.enums.ProfilUtilisateurEnum;
import com.arthus.entitys.converters.ProfilUtilisateurEnumConverter;

@Entity
@Table(name = "UTILISATEURS", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Utilisateur {

    @Id
    @Column(name = "NUMUTIL", nullable = false)
    private Integer numUtil;

    @Column(name = "NOM", length = 30)
    private String nom;

    @Column(name = "PSEUDO", length = 30)
    private String pseudo;

    @Column(name = "INITIALES", length = 5)
    private String initiales;

    @Convert(converter = ProfilUtilisateurEnumConverter.class)
    @Column(name = "PROFIL")
    private ProfilUtilisateurEnum profil;

    @Column(name = "CELLULE")
    private Integer cellule;

    @Column(name = "TEL", length = 14)
    private String tel;

    @Column(name = "NUMUID")
    private Integer numUid;

    @Column(name = "PASSWORD", length = 12)
    private String password;

    @Column(name = "SUPER_USER")
    private Integer superUser;

    @Column(name = "EMAIL", length = 45)
    private String email;

    @Column(name = "PASSWORD_EMAIL", length = 20)
    private String passwordEmail;

    @Column(name = "DATE_FIN")
    private LocalDateTime dateFin;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMUTIL_CREATION", referencedColumnName = "NUMUTIL")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Utilisateur createur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMUTIL_MODIF", referencedColumnName = "NUMUTIL")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Utilisateur modificateur;

    @Column(name = "DATE_CREATION")
    private LocalDateTime creation;

    @Column(name = "DATE_MODIF")
    private LocalDateTime modification;
}
