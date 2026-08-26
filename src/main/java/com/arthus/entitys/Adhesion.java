package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

/*
 * Table ARTHUS.ADHESION - la couverture : "tel individu est couvert par telle
 * garantie (NUMFOR) au titre de telle adhesion (IDADHESION), du DATAPLI au DATPER".
 *
 * A ne pas confondre avec AdhesionContrat (table ADHE_CNTRT, PK IDADHESION), qui
 * est l'adhesion au contrat. Ici la PK est IDCOUVERTURE et IDADHESION n'est qu'une
 * FK : il y a une ligne ADHESION par couple (individu, garantie).
 *
 * C'est cette table qui fournit les colonnes datesous / datper de l'ancienne
 * requete (max(a.datapli), max(a.datper)).
 *
 * Cas "groupe de garanties" (PREV CARCO) : NUMFOR peut valoir un NUMGRPGAR de
 * GRP_GAR au lieu d'un NUMFOR de garantie ; le rattachement se fait alors via
 * GroupeGarantieDef.
 */
@Entity
@Table(name = "ADHESION", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Adhesion {

    @Id
    @Column(name = "IDCOUVERTURE", nullable = false)
    private Long idcouverture;

    /* --- Colonnes brutes : ce sont elles qui servent aux jointures de recherche --- */

    @Column(name = "IDADHESION")
    private Long idadhesion;

    // NUMFOR d'une garantie (GAR_CNTRT_REF.NUMFOR) ou d'un groupe (GRP_GAR.NUMGRPGAR)
    @Column(name = "NUMFOR")
    private Long numfor;

    @Column(name = "NUMINDIV")
    private Long numindiv;

    @Column(name = "NUMGAR")
    private Long numgar;

    /* --- Memes colonnes vues comme associations, en LECTURE SEULE --- */

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "IDADHESION", referencedColumnName = "IDADHESION",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private AdhesionContrat adhesionContrat;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMINDIV", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu individu;

    // Date de souscription / d'effet de la couverture
    @Column(name = "DATAPLI")
    private LocalDate datapli;

    // Date de fin de la couverture
    @Column(name = "DATPER")
    private LocalDate datper;

    @Column(name = "RANG")
    private Integer rang;

    @Column(name = "ETAT")
    private Integer etat;

    @Column(name = "UC")
    private Integer uc;

    @Column(name = "FLAG_REGIME", length = 1)
    private String flagRegime;

    @Column(name = "REGIME")
    private Integer regime;

    @Column(name = "TYPFOR")
    private Integer typfor;

    @Column(name = "NUMORG")
    private Integer numorg;

    @Column(name = "DIS_CARENCE", length = 1)
    private String disCarence;

    @Column(name = "DIS_FRANCHISE", length = 1)
    private String disFranchise;

    @Column(name = "NUMFOR_CARENCE")
    private Long numforCarence;

    @Column(name = "NUMUTIL")
    private Integer numutil;

    @Column(name = "MOTIF")
    private Integer motif;

    @Column(name = "CREATION")
    private LocalDate creation;

    @Column(name = "MAJ")
    private LocalDate maj;
}
