package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

/*
 * Table ARTHUS.PERS_ORGANISME - qualifie un INDIVIDU en tant qu'organisme.
 * PK = NUMINDIV. NUMORG est le numero "metier" de l'organisme (NUMBER(3)),
 * c'est lui que reference CONTRAT_REF.NUMORG.
 *
 * ROLE = 2 designe l'ASSUREUR : c'est le filtre utilise partout dans le legacy
 * (vue ORGANISME, PK_WS_WEB_BACK "recuperation des informations de l'assureur",
 * V_LBLE_EXT).
 *
 * REMB_PREST = 1 marque l'organisme qui rembourse les prestations : c'est le
 * critere de V_ASSUR_DELEGAT, qui determine l'assureur au niveau de la GARANTIE
 * (via GARANTIES.NUMASS / FORMULE.NUMASS) et non du contrat. Voir le README :
 * les deux notions peuvent differer sur un contrat en co-assurance ou en
 * delegation de gestion.
 *
 * Attention : NUMORG n'a qu'un index NON unique (IDX1_PERS_ORGANISME). Il est
 * unique dans les faits, mais Hibernate ne peut pas s'appuyer sur une contrainte
 * pour le garantir - d'ou la remarque sur l'association cote ContratRef.
 */
@Entity
@Table(name = "PERS_ORGANISME", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PersonneOrganisme {

    @Id
    @Column(name = "NUMINDIV", nullable = false)
    private Long numindiv;

    // La personne (morale) derriere l'organisme : nom, adresse, refcie...
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMINDIV", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu individu;

    // Numero metier de l'organisme, reference par CONTRAT_REF.NUMORG
    @Column(name = "NUMORG")
    private Integer numorg;

    // 2 = assureur
    @Column(name = "ROLE")
    private Integer role;

    @Column(name = "PRESCR")
    private Integer prescr;

    @Column(name = "ENTETE1", length = 30)
    private String entete1;

    @Column(name = "ENTETE2", length = 30)
    private String entete2;

    // Porte le code federation dans certains traitements : FFSA / FNMF / CTIP
    @Column(name = "ENTETE3", length = 30)
    private String entete3;

    // 1 = organisme qui rembourse les prestations (critere de V_ASSUR_DELEGAT)
    @Column(name = "REMB_PREST")
    private Integer rembPrest;

    @Column(name = "REVERS_COTIS")
    private Integer reversCotis;

    @Transient
    public boolean isAssureur() {
        return role != null && role == 2;
    }
}