package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/*
 * Table ARTHUS.GAR_CNTRT_REF - la garantie portee par un contrat de reference.
 * PK = NUMFOR. FK NUMGAR -> CONTRAT_REF (la seule FK reellement declaree du lot).
 *
 * Entite mappee sur la TABLE, donc inscriptible (insert/update).
 * L'ancienne requete Forms lisait la vue GAR_CNTRT :
 *     GAR_CNTRT = GAR_CNTRT_REF UNION (ADHE_COLL_GAR jointe a GAR_CNTRT_REF)
 * La 2e branche (garanties propres a une adhesion collective) est donc hors de
 * cette entite - voir AdhesionCollectiveGarantie et le README.
 */
@Entity
@Table(name = "GAR_CNTRT_REF", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GarantieContratRef {

    @Id
    @Column(name = "NUMFOR", nullable = false)
    private Long numfor;

    // Colonne brute NUMGAR : proprietaire de la colonne, inscriptible
    @Column(name = "NUMGAR")
    private Long numgar;

    // Meme colonne, vue comme association en LECTURE SEULE
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMGAR", referencedColumnName = "NUMGAR",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private ContratRef contratRef;

    // Garantie de reference dont celle-ci derive (modele produit)
    @Column(name = "NUMFOR_REF")
    private Long numforRef;

    // Code court de la garantie (8 car.), ex. INCAP
    @Column(name = "NOMGAR", length = 8)
    private String nomgar;

    @Column(name = "LIBELLE", length = 45)
    private String libelle;

    @Column(name = "TYPE")
    private Integer type;

    // 'O' = garantie valide - filtre repris tel quel de l'ancienne requete
    @Column(name = "VALIDE", length = 1)
    private String valide;

    @Column(name = "OBLIGATOIRE", length = 1)
    private String obligatoire;

    // Date d'application (debut de validite de la garantie au contrat)
    @Column(name = "DATAPLI")
    private LocalDate datapli;

    // Date de peremption (fin de validite)
    @Column(name = "DATPER")
    private LocalDate datper;

    /*
     * Composition des groupes qui contiennent cette garantie (GRP_GAR_DEF).
     * Sert au cas PREV CARCO : adhesion faite au groupe et non a la garantie.
     */
    @OneToMany(mappedBy = "garantie", fetch = FetchType.LAZY)
    @Builder.Default
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<GroupeGarantieDef> groupes = new ArrayList<>();

    @Transient
    public boolean isValide() {
        return "O".equals(valide);
    }
}
