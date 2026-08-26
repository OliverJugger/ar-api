package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.time.LocalDate;

/*
 * Table ARTHUS.BENEFICIAIRE - declaration "telle personne (NUMBENE) est
 * beneficiaire de type TYPE_BENE au titre de l'adhesion IDADHESION / garantie
 * NUMFOR de l'assure NUMINDIV".
 *
 * La table n'a pas de PK declaree en base. La procedure ARTHUS.ins_bene teste
 * l'unicite sur (IDADHESION, NUMFOR, NUMINDIV, NUMBENE) : on reprend ce quadruplet
 * comme cle composite.
 *
 * Attention aux deux colonnes "personne" :
 *   - NUMINDIV = l'assure (celui du dossier sinistre),
 *   - NUMBENE  = le beneficiaire, qui est lui aussi un NUMINDIV
 *                (bene.numindiv = beneficiaire.numbene dans PK_PRDG_FONCT).
 *
 * Cette entite n'est utile que pour recuperer TYPE_BENE (mnemo LIBELLE
 * 'TYPE_BENE', meme principe que RisqueEnum) : la liste des beneficiaires d'un
 * sinistre, elle, se lit via RepartitionBene.
 */
@Entity
@Table(name = "BENEFICIAIRE", schema = "ARTHUS")
@IdClass(Beneficiaire.BeneficiaireId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Beneficiaire {

    @Id
    @Column(name = "IDADHESION", nullable = false)
    private Long idadhesion;

    @Id
    @Column(name = "NUMFOR", nullable = false)
    private Long numfor;

    // L'assure
    @Id
    @Column(name = "NUMINDIV", nullable = false)
    private Long numindiv;

    // Le beneficiaire (= un NUMINDIV lui aussi)
    @Id
    @Column(name = "NUMBENE", nullable = false)
    private Long numbene;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMBENE", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu personne;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMINDIV", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu assure;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMFOR", referencedColumnName = "NUMFOR",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private GarantieContratRef garantie;

    // Mnemo LIBELLE = 'TYPE_BENE' (conjoint, enfant, entreprise...)
    @Column(name = "TYPE_BENE")
    private Integer typeBene;

    @Column(name = "VALIDE", length = 1)
    private String valide;

    @Column(name = "CREATION")
    private LocalDate creation;

    @Column(name = "MAJ")
    private LocalDate maj;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BeneficiaireId implements Serializable {
        private Long idadhesion;
        private Long numfor;
        private Long numindiv;
        private Long numbene;
    }
}
