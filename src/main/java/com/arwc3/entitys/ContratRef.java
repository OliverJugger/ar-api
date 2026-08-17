package com.arwc3.entitys;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Table ARTHUS.CONTRAT_REF — le "Contrat".
 * PK = NUMGAR. C'est le point d'entrée demandé pour retrouver les DossierSinistre.
 */
@Entity
@Table(name = "CONTRAT_REF", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContratRef {

    @Id
    @Column(name = "NUMGAR", nullable = false)
    private Long numgar;

    /* --- Lien inverse : un contrat porte plusieurs adhésions --- */
    @OneToMany(mappedBy = "contratRef", fetch = FetchType.LAZY)
    @Builder.Default
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<AdheCntrt> adhesions = new ArrayList<>();

    @Column(name = "NUMGAR_REF")
    private Long numgarRef;

    @Column(name = "REFCIE", length = 30)
    private String refcie;

    @Column(name = "REFCIE_CHAPEAU", length = 25)
    private String refcieChapeau;

    @Column(name = "NUMORG")
    private Integer numorg;

    @Column(name = "NUMPROD")
    private Long numprod;

    @Column(name = "NUMCLI")
    private Long numcli;

    @Column(name = "NUMINTERM")
    private Long numinterm;

    @Column(name = "NUMUTIL")
    private Integer numutil;

    @Column(name = "TYPGAR")
    private Integer typgar;

    @Column(name = "COLLEGE")
    private Integer college;

    @Column(name = "MODE_GESTION")
    private Integer modeGestion;

    @Column(name = "TYPE_CONTRAT")
    private Integer typeContrat;

    @Column(name = "DATSOUS")
    private LocalDateTime datsous;

    @Column(name = "DATEFF")
    private LocalDateTime dateff;

    @Column(name = "GEST_COTIS")
    private Integer gestCotis;

    @Column(name = "NAT_CALC")
    private Integer natCalc;

    @Column(name = "TYPE_TERME")
    private Integer typeTerme;

    @Column(name = "TYPEQUIT")
    private Integer typequit;

    @Column(name = "TYPE_CALC")
    private Integer typeCalc;

    @Column(name = "MODE_CALCUL")
    private Integer modeCalcul;

    @Column(name = "FRACT")
    private Integer fract;

    @Column(name = "ARRONDI")
    private Integer arrondi;

    @Column(name = "MREGL")
    private Integer mregl;

    @Column(name = "ECHE_ANNIV")
    private LocalDateTime echeAnniv;

    @Column(name = "REVISION")
    private Integer revision;

    @Column(name = "DELAI")
    private Integer delai;

    @Column(name = "NUMQUERABLE")
    private Long numquerable;

    @Column(name = "DELEGATAIRE")
    private Long delegataire;

    @Column(name = "DESTINATAIRE")
    private Long destinataire;

    @Column(name = "GEST_PREST")
    private Integer gestPrest;

    @Column(name = "DELEG_PREST")
    private Long delegPrest;

    @Column(name = "DERECHE")
    private LocalDateTime dereche;

    @Column(name = "ECHESUIV")
    private LocalDateTime echesuiv;

    @Column(name = "CELLULE")
    private Integer cellule;

    @Column(name = "RENOUV")
    private Integer renouv;

    @Column(name = "TYPE_ECHE")
    private Integer typeEche;

    @Column(name = "PORTEFEUILLE", length = 15)
    private String portefeuille;

    @Column(name = "CT_RESP")
    private Integer ctResp;

    @Column(name = "MARQUE")
    private Integer marque;

    @Column(name = "ASSIST_NUM")
    private Long assistNum;

    @Column(name = "ASSIST_NOM", length = 45)
    private String assistNom;

    @Column(name = "ASSIST_TEL", length = 45)
    private String assistTel;
}
