package com.arthus.entitys.contextuel;

import jakarta.persistence.*;
import lombok.*;

import com.arthus.entitys.Individu;
import com.arthus.entitys.Repartition;
import com.arthus.entitys.enums.ContexteEnum;
import com.arthus.entitys.converters.ContexteEnumConverter;

import java.time.LocalDate;

/*
 * Table ARTHUS.PIECES - les pieces justificatives demandees sur un objet metier.
 * PK = IDPIECE, alimentee par la sequence ARTHUS.IDPIECE.
 *
 * Meme mecanique generique que CORRESPONDANT : (CONTEXTE, ENTITE).
 *   SINISTRE_PREVOYANCE (15)              -> ENTITE = le NOSIN
 *   BENEFICIAIRE_SINISTRE_PREVOYANCE (17) -> ENTITE = le NOSIN aussi, c'est
 *                                            NUMBENE qui designe le beneficiaire
 * (PK_WS_WEB_BACK : "WHERE p.entite = p_nosin AND p.contexte = 17" ;
 *  PK_PRDG_FONCT.F_get_piece : "WHERE nopiece = ... AND CONTEXTE = 15 AND entite = p_numsin".)
 *
 * Cycle de vie d'une demande, tel qu'il se lit dans PK_MAIL :
 *   DATEAVIS / DATEREL renseignees et DATERECEP + DATANNUL nulles = piece en
 *   attente. DATERECEP la solde, DATANNUL l'annule. NBREL compte les relances.
 *
 * Aucune FK en base, aucun index sur IDPIECE seul : les acces passent par
 * (ENTITE, NUMBENE) ou (IDREPARTITION, ENTITE), cf. IDX1_PIECES a IDX3_PIECES.
 */
@Entity
@Table(name = "PIECES", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Piece implements EntiteContextuelle {

    @Id
    @Column(name = "IDPIECE", nullable = false)
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seqIdPiece")
    @SequenceGenerator(name = "seqIdPiece", schema = "ARTHUS",
                       sequenceName = "IDPIECE", allocationSize = 1)
    private Long idpiece;

    // Referentiel LIBELLE 'CONTE'
    @Convert(converter = ContexteEnumConverter.class)
    @Column(name = "CONTEXTE")
    private ContexteEnum contexte;

    // Cle de l'objet vise. Pour les contextes 15 et 17 : TO_NUMBER(NOSIN)
    @Column(name = "ENTITE")
    private Long entite;

    // Nature de la piece demandee (referentiel a confirmer en base)
    @Column(name = "NOPIECE")
    private Integer nopiece;

    /* --- Beneficiaire concerne --- */

    @Column(name = "NUMBENE")
    private Long numbene;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMBENE", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu beneficiaire;

    /* --- Destinataire de la demande --- */

    @Column(name = "NUMINDIV_DEST")
    private Long numindivDest;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMINDIV_DEST", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu destinataire;

    /* --- Repartition d'origine : ici le lien est une vraie colonne typee --- */

    @Column(name = "IDREPARTITION")
    private Long idrepartition;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "IDREPARTITION", referencedColumnName = "IDREPARTITION",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Repartition repartition;

    // Garantie concernee (GAR_CNTRT_REF.NUMFOR)
    @Column(name = "NUMFOR")
    private Long numfor;

    @Column(name = "NUMENVOI")
    private Long numenvoi;

    /* --- Cycle de vie --- */

    @Column(name = "DATEENREG")
    private LocalDate dateenreg;

    // Date de l'avis initial
    @Column(name = "DATEAVIS")
    private LocalDate dateavis;

    // Date de reception : solde la demande
    @Column(name = "DATERECEP")
    private LocalDate daterecep;

    // Date de la derniere relance
    @Column(name = "DATEREL")
    private LocalDate daterel;

    @Column(name = "DATANNUL")
    private LocalDate datannul;

    // Nombre de relances envoyees
    @Column(name = "NBREL")
    private Integer nbrel;

    @Column(name = "DELAI")
    private Integer delai;

    @Column(name = "PERIOD")
    private Integer period;

    // 'O' = piece bloquante
    @Column(name = "BLOC", length = 1)
    private String bloc;

    @Column(name = "RENOUV", length = 1)
    private String renouv;

    @Column(name = "COMMENTAIRE", length = 200)
    private String commentaire;
}
