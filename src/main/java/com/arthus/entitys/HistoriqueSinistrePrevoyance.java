package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import com.arthus.entitys.enums.EtatSinistrePrevoyanceEnum;
import com.arthus.entitys.converters.EtatSinistrePrevoyanceEnumConverter;
import com.arthus.entitys.enums.MotifFinEnum;
import com.arthus.entitys.converters.MotifFinEnumConverter;

import java.io.Serializable;
import java.time.LocalDateTime;

/*
 * Table ARTHUS.HISTO_SNTR_PREV - l'historique des etats d'un sinistre prevoyance.
 * PK composite = (NOSIN, DEBUT). FK NOSIN -> SNTR_PREV (FK1_HISTO_SNTR_PREV).
 *
 * Une ligne = un changement d'etat a la date DEBUT, avec son motif et l'utilisateur
 * qui l'a saisi. L'etat courant du sinistre est donc la ligne de DEBUT maximum
 * (inferieur ou egal a la date d'observation) - c'est exactement ce que fait
 * PK_EXTRACTION_AUTO :
 *     histo.debut = (select max(h.debut) from histo_sntr_prev h
 *                     where h.nosin = s.nosin and debut <= :date)
 *
 * ETAT (mnemo LIBELLE 'HISTO_SITU') : 1 = ouverture, 2 = fermeture. PK_PREV insere
 * un ETAT=2 pour fermer un sinistre, et PK_PRDG_FONCT.P_get_histo_sinistre_prev
 * lit ETAT=1 pour l'ouverture, ETAT=2 pour la fermeture.
 *
 * MOTIF partage le referentiel de SNTR_PREV.MOTIF, donc MotifFinEnum : on y
 * retrouve 10 = erreur de saisie et 19 = rechute, tous deux utilises en dur dans
 * le legacy.
 *
 * Attention : DEBUT faisant partie de la cle, deux changements d'etat le meme jour
 * a la meme heure sont impossibles. Le legacy insere sysdate (avec l'heure), pas
 * trunc(sysdate) - ne tronque donc pas la date cote Java.
 */
@Entity
@Table(name = "HISTO_SNTR_PREV", schema = "ARTHUS")
@IdClass(HistoriqueSinistrePrevoyance.HistoriqueSinistrePrevoyanceId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HistoriqueSinistrePrevoyance {

    // Colonne brute NOSIN : proprietaire de la colonne et 1re partie de la cle
    @Id
    @Column(name = "NOSIN", length = 9, nullable = false)
    private String nosin;

    // Date de prise d'effet de l'etat, 2e partie de la cle
    @Id
    @Column(name = "DEBUT", nullable = false)
    private LocalDateTime debut;

    /*
     * Meme colonne NOSIN, vue comme association, en LECTURE SEULE.
     * Pour creer une ligne d'historique, valorise nosin (ou passe par le helper
     * SinistrePrevoyance.ajouterHistorique) : c'est le champ brut qui ecrit.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NOSIN", referencedColumnName = "NOSIN",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private SinistrePrevoyance sinistrePrevoyance;

    @Convert(converter = EtatSinistrePrevoyanceEnumConverter.class)
    @Column(name = "ETAT")
    private EtatSinistrePrevoyanceEnum etat;

    @Convert(converter = MotifFinEnumConverter.class)
    @Column(name = "MOTIF")
    private MotifFinEnum motif;

    // Utilisateur ayant saisi le changement d'etat
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMUTIL", referencedColumnName = "NUMUTIL")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Utilisateur saisiPar;

    // Date de saisie effective, distincte de DEBUT (date d'effet)
    @Column(name = "SAISIE")
    private LocalDateTime saisie;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class HistoriqueSinistrePrevoyanceId implements Serializable {
        private String nosin;
        private LocalDateTime debut;
    }
}
