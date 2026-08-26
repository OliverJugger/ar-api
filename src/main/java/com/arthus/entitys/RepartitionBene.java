package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

/*
 * Table ARTHUS.REPARTITION_BENE - le beneficiaire d'une repartition, avec sa
 * quote-part. PK composite = (IDREPARTITION, NUMBENE).
 *
 * C'est le maillon qui relie un sinistre a ses beneficiaires :
 * SNTR_PREV -> REPARTITION (VALIDE='O') -> REPARTITION_BENE (VALIDE='O').
 * Voir les vues V_REPARTITION_BENE / V_CORRES_MAIL / V_BENE_JUSTIF_SIN qui
 * appliquent exactement ce double filtre.
 *
 * NUMBENE EST UN NUMINDIV : les packages legacy joignent
 * individu.numindiv = repartition_bene.numbene (PK_PRDG_FONCT, PK_EXTRACTION_AUTO).
 * D'ou l'association directe vers Individu. NUMBENE_DEST est le destinataire du
 * reglement (souvent different du beneficiaire : entreprise, tuteur...).
 */
@Entity
@Table(name = "REPARTITION_BENE", schema = "ARTHUS")
@IdClass(RepartitionBene.RepartitionBeneId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RepartitionBene {

    @Id
    @Column(name = "IDREPARTITION", nullable = false)
    private Long idrepartition;

    @Id
    @Column(name = "NUMBENE", nullable = false)
    private Long numbene;

    // IDREPARTITION vu comme association, en LECTURE SEULE
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "IDREPARTITION", referencedColumnName = "IDREPARTITION",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Repartition repartition;

    // NUMBENE vu comme association vers la personne, en LECTURE SEULE
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMBENE", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu beneficiaire;

    // Destinataire du reglement (peut differer du beneficiaire)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMBENE_DEST", referencedColumnName = "NUMINDIV")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu destinataire;

    // Quote-part du beneficiaire, en pourcentage
    @Column(name = "POURCENT", precision = 12, scale = 5)
    private BigDecimal pourcent;

    @Column(name = "DEBUT")
    private LocalDate debut;

    @Column(name = "FIN")
    private LocalDate fin;

    // 'O' = ligne valide. Filtre obligatoire, comme sur REPARTITION
    @Column(name = "VALIDE", length = 1)
    private String valide;

    @Column(name = "ETAT")
    private Integer etat;

    // 1=BEN (beneficiaire), 2=ENT (entreprise), 3=ASS (assure), 8=TUT (tuteur) - cf. PK_PRDG_FONCT
    @Column(name = "TYPE_DEST")
    private Integer typeDest;

    @Column(name = "TRAITE", length = 1)
    private String traite;

    @Column(name = "ECHESUIV")
    private LocalDate echesuiv;

    @Column(name = "FRACT")
    private Integer fract;

    @Column(name = "NUMDEST_PJ")
    private Long numdestPj;

    @Column(name = "EXCLU_DDE_PJ", length = 1)
    private String excluDdePj;

    @Column(name = "IRREVOCABLE", length = 1)
    private String irrevocable;

    @Column(name = "MODE_RGLT")
    private Integer modeRglt;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RepartitionBeneId implements Serializable {
        private Long idrepartition;
        private Long numbene;
    }
}
