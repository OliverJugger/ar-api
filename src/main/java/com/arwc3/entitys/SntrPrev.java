package com.arwc3.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Table ARTHUS.SNTR_PREV — le sinistre prévoyance.
 * PK = NOSIN. Porte IDDOSSIER (FK vers DOSSIER_SINISTRE).
 *
 * IDDOSSIER n'est pas unique ici : plusieurs sinistres peuvent viser le même
 * dossier — d'où le @ManyToOne vers DossierSinistre.
 */
@Entity
@Table(name = "SNTR_PREV", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SntrPrev {

    @Id
    @Column(name = "NOSIN", length = 9, nullable = false)
    private String nosin;

    /* --- FK IDDOSSIER vers DOSSIER_SINISTRE --- */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "IDDOSSIER", referencedColumnName = "IDDOSSIER")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private DossierSinistre dossierSinistre;

    /* --- Lien inverse : un sinistre a plusieurs répartitions --- */
    @OneToMany(mappedBy = "sntrPrev", fetch = FetchType.LAZY)
    @Builder.Default
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<Repartition> repartitions = new ArrayList<>();

    @Column(name = "SURVENANCE")
    private LocalDateTime survenance;

    @Column(name = "DECLARATION")
    private LocalDateTime declaration;

    @Column(name = "NORISQ")
    private Integer norisq;

    @Column(name = "CAUSE")
    private Integer cause;

    @Column(name = "IDCORRES")
    private Long idcorres;

    @Column(name = "NUMUTIL")
    private Integer numutil;

    @Column(name = "NUMCLOT")
    private Long numclot;

    @Column(name = "CREATION")
    private LocalDateTime creation;

    @Column(name = "MAJ")
    private LocalDateTime maj;

    @Column(name = "FIN")
    private LocalDateTime fin;

    @Column(name = "MOTIF")
    private Integer motif;

    @Column(name = "CREATEUR")
    private Integer createur;

    @Column(name = "MODIFICATION")
    private LocalDateTime modification;

    @Column(name = "MODIFICATEUR")
    private Integer modificateur;

    @Column(name = "REF_EXT_1", length = 10)
    private String refExt1;

    @Column(name = "REF_EXT_2")
    private Long refExt2;

    @Column(name = "DC_ASSURE", length = 1)
    private String dcAssure;

    @Column(name = "PRISCHARGE")
    private LocalDateTime prischarge;

    /** Information complémentaire 1, Mnémo INF_DS1. */
    @Column(name = "INFO_COMP1")
    private Integer infoComp1;

    /** Information complémentaire 2, Mnémo INF_DS2. */
    @Column(name = "INFO_COMP2")
    private Integer infoComp2;

    /** Date de prise en charge calculée. */
    @Column(name = "PRISCALC")
    private LocalDateTime priscalc;
}
