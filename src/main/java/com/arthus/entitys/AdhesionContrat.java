package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Table ARTHUS.ADHE_CNTRT — l'adhésion au contrat.
 * PK = IDADHESION. Porte NUMGAR (FK vers CONTRAT_REF).
 *
 * NUMGAR est exposé à la fois :
 *   - en colonne brute 'numgar', utilisée pour filtrer sans jointure,
 *   - en association 'contratRef' en lecture seule pour la navigation objet.
 */
@Entity
@Table(name = "ADHE_CNTRT", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdhesionContrat {

    @Id
    @Column(name = "IDADHESION", nullable = false)
    private Long idadhesion;

    /* --- Colonne brute NUMGAR (propriétaire de la colonne) --- */
    @Column(name = "NUMGAR")
    private Long numgar;

    /* --- Même colonne, vue comme association en LECTURE SEULE --- */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMGAR", referencedColumnName = "NUMGAR",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private ContratRef contratRef;

    /* --- Lien inverse : une adhésion a plusieurs répartitions --- */
    @OneToMany(mappedBy = "adhesionContrat", fetch = FetchType.LAZY)
    @Builder.Default
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<Repartition> repartitions = new ArrayList<>();

    @Column(name = "REF_EXT", length = 30)
    private String refExt;

    @Column(name = "NUMADHE")
    private Long numadhe;

    @Column(name = "DATE_ADHE")
    private LocalDateTime dateAdhe;

    @Column(name = "MEME_GAR", length = 1)
    private String memeGar;

    @Column(name = "DATE_FIN_ADHE")
    private LocalDateTime dateFinAdhe;

    @Column(name = "NUMQUERABLE")
    private Long numquerable;

    @Column(name = "FRACT")
    private Integer fract;

    @Column(name = "ECHESUIV")
    private LocalDateTime echesuiv;

    @Column(name = "DERECHE")
    private LocalDateTime dereche;

    @Column(name = "MREGL")
    private Integer mregl;

    @Column(name = "DELAI")
    private Integer delai;

    @Column(name = "DSOUS")
    private LocalDateTime dsous;

    @Column(name = "NUMUTIL")
    private Integer numutil;

    @Column(name = "ECHE_ANNIV")
    private LocalDateTime echeAnniv;
}
