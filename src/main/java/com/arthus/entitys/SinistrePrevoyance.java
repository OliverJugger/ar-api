package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import jakarta.persistence.Convert;
import com.arthus.entitys.enums.RisqueEnum;
import com.arthus.entitys.converters.RisqueEnumConverter;
import com.arthus.entitys.enums.MotifFinEnum;
import com.arthus.entitys.converters.MotifFinEnumConverter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/*
 * Table ARTHUS.SNTR_PREV - le sinistre prevoyance.
 * PK = NOSIN. Porte IDDOSSIER (FK vers DOSSIER_SINISTRE).
 *
 * IDDOSSIER n'est pas unique ici : plusieurs sinistres peuvent viser le meme
 * dossier - d'ou le @ManyToOne vers DossierSinistre.
 *
 * Garanties et beneficiaires passent tous les deux par REPARTITION :
 *
 *   SNTR_PREV --(NOSIN)--> REPARTITION (VALIDE='O')
 *                              |--(NUMFOR)---------> GAR_CNTRT_REF   = garanties
 *                              |--(IDREPARTITION)--> REPARTITION_BENE (VALIDE='O')
 *                                                       |--(NUMBENE = NUMINDIV)--> INDIVIDU
 *
 * Cette entite ne fait QUE le mapping. La traversee (filtre VALIDE = 'O',
 * dedoublonnage, dates de couverture) est dans SinistreGarantieService, pour
 * trois raisons :
 *   - un raccourci @ManyToMany sur REPARTITION mappait la meme table deux fois,
 *     avec deux etats qui divergent des qu'on modifie une repartition ;
 *   - des getters derives sur Repartition.garantie (@ManyToOne LAZY) declenchent
 *     un select par repartition : un N+1 invisible depuis l'appelant ;
 *   - hors transaction, ces memes getters levent LazyInitializationException.
 * Le service, lui, charge en une requete avec join fetch.
 */
@Entity
@Table(name = "SNTR_PREV", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SinistrePrevoyance {

    @Id
    @Column(name = "NOSIN", length = 9, nullable = false)
    private String nosin;

    // FK IDDOSSIER vers DOSSIER_SINISTRE
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "IDDOSSIER", referencedColumnName = "IDDOSSIER")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private DossierSinistre dossierSinistre;

    // Lien inverse : un sinistre a plusieurs repartitions (une par garantie)
    @OneToMany(mappedBy = "sinistrePrevoyance", fetch = FetchType.LAZY)
    @Builder.Default
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<Repartition> repartitions = new ArrayList<>();

    /*
     * Lien inverse : l'historique des etats du sinistre (HISTO_SNTR_PREV).
     * Trie par date d'effet decroissante, la ligne la plus recente en premier.
     */
    @OneToMany(mappedBy = "sinistrePrevoyance", fetch = FetchType.LAZY)
    @OrderBy("debut DESC")
    @Builder.Default
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<HistoriqueSinistrePrevoyance> historiques = new ArrayList<>();

    @Column(name = "SURVENANCE")
    private LocalDateTime survenance;

    @Column(name = "DECLARATION")
    private LocalDateTime declaration;

    @Column(name = "PRISCHARGE")
    private LocalDateTime prischarge;

    // Date de prise en charge calculee
    @Column(name = "PRISCALC")
    private LocalDateTime priscalc;

    @Convert(converter = RisqueEnumConverter.class)
    @Column(name = "NORISQ")
    private RisqueEnum risque;

    @Column(name = "CAUSE")
    private Integer cause;

    @Column(name = "IDCORRES")
    private Long idcorres;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMUTIL", referencedColumnName = "NUMUTIL")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Utilisateur gestionnaire;

    @Column(name = "NUMCLOT")
    private Long numclot;

    @Convert(converter = MotifFinEnumConverter.class)
    @Column(name = "MOTIF")
    private MotifFinEnum motif;

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

    // Information complementaire 1, Mnemo INF_DS1
    @Column(name = "INFO_COMP1")
    private Integer infoComp1;

    // Information complementaire 2, Mnemo INF_DS2
    @Column(name = "INFO_COMP2")
    private Integer infoComp2;

    @Column(name = "CREATION")
    private LocalDateTime creation;

    @Column(name = "MAJ")
    private LocalDateTime maj;

    @Column(name = "FIN")
    private LocalDateTime fin;
}
