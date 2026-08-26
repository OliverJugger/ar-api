package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

/*
 * Table ARTHUS.REPARTITION - table pivot entre le sinistre (SNTR_PREV via NOSIN)
 * et l'adhesion (ADHE_CNTRT via IDADHESION).
 *
 * C'est cette table qui materialise la fonction f_idadhesion_prev :
 *     f_idadhesion_prev(nosin) = select IDADHESION where NOSIN = :nosin and VALIDE = 'O'
 * Le filtre valide = 'O' est donc la cle du lien "valide".
 *
 * Role central pour les garanties et les beneficiaires : il y a une ligne
 * REPARTITION par couple (sinistre, garantie). NUMFOR porte la garantie
 * (GarantieContratRef), et REPARTITION_BENE porte les beneficiaires de cette
 * garantie avec leur quote-part. La liste des garanties d'un sinistre = la liste
 * des NUMFOR de ses repartitions valides ; la liste des beneficiaires = l'union
 * des REPARTITION_BENE valides de ces repartitions.
 */
@Entity
@Table(name = "REPARTITION", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Repartition {

    @Id
    @Column(name = "IDREPARTITION", nullable = false)
    private Long idrepartition;

    // FK IDADHESION vers ADHE_CNTRT
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "IDADHESION", referencedColumnName = "IDADHESION")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private AdhesionContrat adhesionContrat;

    // FK NOSIN vers SNTR_PREV
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NOSIN", referencedColumnName = "NOSIN")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private SinistrePrevoyance sinistrePrevoyance;

    // Colonne brute NUMFOR : proprietaire de la colonne
    @Column(name = "NUMFOR")
    private Long numfor;

    /*
     * Meme colonne, vue comme association vers la garantie, en LECTURE SEULE.
     * C'est numfor qui reste porteur de la colonne : un insert/update de
     * repartition se fait en valorisant numfor, pas cette association.
     *
     * Cas limite : si NUMFOR designe une garantie d'adhesion collective
     * (ADHE_COLL_GAR), aucune ligne GAR_CNTRT_REF ne correspond. Avec un proxy
     * LAZY, l'acces leverait alors EntityNotFoundException. Deux reponses
     * possibles : ajouter @NotFound(action = NotFoundAction.IGNORE) (l'association
     * devient EAGER et vaut null), ou verifier d'abord que le cas n'existe pas
     * chez tes clients - cf. AdhesionCollectiveGarantie et le README.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMFOR", referencedColumnName = "NUMFOR",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private GarantieContratRef garantie;

    // Lien inverse : les beneficiaires de cette repartition (avec quote-part)
    @OneToMany(mappedBy = "repartition", fetch = FetchType.LAZY)
    @Builder.Default
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<RepartitionBene> beneficiaires = new ArrayList<>();

    @Column(name = "TYPE_CALC")
    private Integer typeCalc;

    // 'O' = repartition valide (voir f_idadhesion_prev), 'N' sinon
    @Column(name = "VALIDE", length = 1)
    private String valide;

    @Column(name = "PERIODE")
    private Integer periode;

    @Column(name = "GEST_CALC")
    private Integer gestCalc;

    // Franchise controlee (O/N)
    @Column(name = "FRAN_CONT", length = 1)
    private String franCont;

    /* ------------------------------------------------------------------ */
    /* Helpers                                                             */
    /* ------------------------------------------------------------------ */

    @Transient
    public boolean isValide() {
        return "O".equals(valide);
    }

    // Beneficiaires valides de la repartition (REPARTITION_BENE.VALIDE = 'O')
    @Transient
    public List<RepartitionBene> getBeneficiairesValides() {
        return beneficiaires.stream()
                .filter(rb -> "O".equals(rb.getValide()))
                .toList();
    }
}
