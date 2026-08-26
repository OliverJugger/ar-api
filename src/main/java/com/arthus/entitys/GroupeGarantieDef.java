package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;

/*
 * Table ARTHUS.GRP_GAR_DEF - composition d'un groupe de garanties :
 * "le groupe NUMGRPGAR contient la garantie NUMFOR".
 *
 * Sert au 2e terme de l'UNION de l'ancienne requete ("PREV CARCO : prise en compte
 * des groupes de garanties") : quand l'individu a adhere au groupe
 * (ADHESION.NUMFOR = GRP_GAR_DEF.NUMGRPGAR) et non a la garantie unitaire.
 *
 * La table n'a pas de PK en base : on declare une cle composite
 * (NUMGRPGAR, NUMFOR) qui est de fait unique.
 */
@Entity
@Table(name = "GRP_GAR_DEF", schema = "ARTHUS")
@IdClass(GroupeGarantieDef.GroupeGarantieDefId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GroupeGarantieDef {

    @Id
    @Column(name = "NUMGRPGAR", nullable = false)
    private Long numgrpgar;

    @Id
    @Column(name = "NUMFOR", nullable = false)
    private Long numfor;

    @Column(name = "TYPFOR")
    private Integer typfor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMFOR", referencedColumnName = "NUMFOR",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private GarantieContratRef garantie;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GroupeGarantieDefId implements Serializable {
        private Long numgrpgar;
        private Long numfor;
    }
}
