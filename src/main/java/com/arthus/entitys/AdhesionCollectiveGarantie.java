package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

/*
 * Table ARTHUS.ADHE_COLL_GAR - garantie propre a une adhesion collective.
 * PK = NUMFOR (espace de valeurs disjoint de celui de GAR_CNTRT_REF).
 *
 * C'est la 2e branche de la vue GAR_CNTRT que lisait l'ancienne requete : la
 * garantie "instanciee" sur l'adhesion collective, qui pointe vers la garantie du
 * contrat de reference via NUMFOR_REF (d'ou elle tire NOMGAR, LIBELLE et TYPE -
 * ces trois colonnes n'existent pas ici).
 *
 * A mapper seulement si tes clients utilisent les adhesions collectives cote
 * prevoyance : dans le schema fourni, ADHE_COLL_GAR n'est referencee que par
 * PK_QTTC (quittancement) et les vues, aucun package PREV. Verifie avec :
 *
 *   SELECT COUNT(*) FROM repartition r
 *    WHERE r.valide = 'O'
 *      AND EXISTS (SELECT 1 FROM adhe_coll_gar g WHERE g.numfor = r.numfor);
 *
 * Si le compte est a 0, GarantieContratRef suffit et cette entite peut sauter.
 */
@Entity
@Table(name = "ADHE_COLL_GAR", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdhesionCollectiveGarantie {

    @Id
    @Column(name = "NUMFOR", nullable = false)
    private Long numfor;

    // Colonne brute NUMFOR_REF : la garantie du contrat de reference
    @Column(name = "NUMFOR_REF")
    private Long numforRef;

    // Meme colonne, vue comme association en LECTURE SEULE
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMFOR_REF", referencedColumnName = "NUMFOR",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private GarantieContratRef garantieRef;

    // NUMGAR de l'adhesion collective (ADHE_COLLECTIVE), pas de CONTRAT_REF
    @Column(name = "NUMGAR")
    private Long numgar;

    // NUMGAR du contrat de reference porteur
    @Column(name = "NUMGAR_REF")
    private Long numgarRef;

    @Column(name = "VALIDE", length = 1)
    private String valide;

    @Column(name = "OBLIGATOIRE", length = 1)
    private String obligatoire;

    @Column(name = "DATAPLI")
    private LocalDate datapli;

    @Column(name = "DATPER")
    private LocalDate datper;

    // Libelle herite de la garantie de reference (la table n'en porte pas)
    @Transient
    public String getLibelle() {
        return garantieRef != null ? garantieRef.getLibelle() : null;
    }

    @Transient
    public String getNomgar() {
        return garantieRef != null ? garantieRef.getNomgar() : null;
    }
}
