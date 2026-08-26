package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "DOSSIER_SINISTRE", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DossierSinistre {

    @Id
    @Column(name = "IDDOSSIER", length = 9, nullable = false)
    private String idDossier;

    @Column(name = "REF_EXT", length = 30)
    private String refExt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMINDIV", referencedColumnName = "NUMINDIV")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu assure;

    /* --- lien inverse vers les sinistres prévoyance --- */
    @OneToMany(mappedBy = "dossierSinistre", fetch = FetchType.LAZY)
    @Builder.Default
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<SinistrePrevoyance> sinistres = new ArrayList<>();

    @Column(name = "ANTERIEUR", length = 1)
    private String anterieur;

    @Column(name = "DEBUT")
    private LocalDateTime debut;

    @Column(name = "FIN")
    private LocalDateTime fin;

    @Column(name = "CLOTURE")
    private LocalDateTime cloture;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMUTIL", referencedColumnName = "NUMUTIL")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Utilisateur gestionnaire;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CREATEUR", referencedColumnName = "NUMUTIL")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Utilisateur createur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MODIFICATEUR", referencedColumnName = "NUMUTIL")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Utilisateur modificateur;

    @Column(name = "CREATION")
    private LocalDateTime creation;

    @Column(name = "MODIFICATION")
    private LocalDateTime modification;
}
