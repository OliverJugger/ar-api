package com.arwc3.entitys;

import jakarta.persistence.*;
import lombok.*;

/**
 * Table ARTHUS.REPARTITION — table pivot entre le sinistre (SNTR_PREV via NOSIN)
 * et l'adhésion (ADHE_CNTRT via IDADHESION).
 *
 * C'est cette table qui matérialise la fonction f_idadhesion_prev :
 *     f_idadhesion_prev(nosin) = select IDADHESION where NOSIN = :nosin and VALIDE = 'O'
 * Le filtre {@code valide = 'O'} est donc la clé du lien "valide".
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

    /* --- FK IDADHESION vers ADHE_CNTRT --- */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "IDADHESION", referencedColumnName = "IDADHESION")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private AdheCntrt adheCntrt;

    /* --- FK NOSIN vers SNTR_PREV --- */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NOSIN", referencedColumnName = "NOSIN")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private SntrPrev sntrPrev;

    @Column(name = "NUMFOR")
    private Long numfor;

    @Column(name = "TYPE_CALC")
    private Integer typeCalc;

    /** 'O' = répartition valide (voir f_idadhesion_prev), 'N' sinon. */
    @Column(name = "VALIDE", length = 1)
    private String valide;

    @Column(name = "PERIODE")
    private Integer periode;

    @Column(name = "GEST_CALC")
    private Integer gestCalc;

    /** Franchise contrôlée (O/N). */
    @Column(name = "FRAN_CONT", length = 1)
    private String franCont;
}
