package com.arwc3.entitys;

import java.util.List;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.ArrayList;

@Entity
@Table(name = "INDIVIDU", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Individu {

    @Id
    @Column(name = "NUMINDIV", nullable = false)
    private Long numindiv;

    @OneToMany(mappedBy = "individu", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<DossierSinistre> dossiers = new ArrayList<>();

    @Column(name = "TYPE")
    private Integer type;

    @Column(name = "NOM", length = 30)
    private String nom;

    @Column(name = "QUALITE")
    private Integer qualite;

    @Column(name = "PRENOM", length = 30)
    private String prenom;

    @Column(name = "DATNAIS")
    private LocalDate datnais;

    @Column(name = "REFCIE", length = 30)
    private String refcie;

    @Column(name = "CODCOURRIER1")
    private Integer codcourrier1;

    @Column(name = "CODCOURRIER2")
    private Integer codcourrier2;

    @Column(name = "CODTITRE")
    private Integer codtitre;

    @Column(name = "SEXE")
    private Integer sexe;

    @Column(name = "POTENTIEL")
    private Integer potentiel;

    @Column(name = "NOMJF", length = 30)
    private String nomjf;

    @Column(name = "CREATION")
    private LocalDate creation;

    @Column(name = "MAJ")
    private LocalDate maj;

    @Column(name = "NUMUTIL")
    private Integer numutil;

    @Column(name = "NUMASSU")
    private Long numassu;

    @Column(name = "TYPASSU")
    private Integer typassu;

    @Column(name = "TYPADR")
    private Integer typadr;

    @Column(name = "REGIME", length = 2)
    private String regime;

    @Column(name = "ORGBASE")
    private Integer orgbase;

    @Column(name = "MATORG", length = 20)
    private String matorg;

    @Column(name = "CLESS")
    private Integer cless;

    @Column(name = "RANG")
    private Integer rang;

    @Column(name = "NATUR", length = 2)
    private String natur;

    @Column(name = "CAISSE", length = 3)
    private String caisse;

    @Column(name = "TEL", length = 45)
    private String tel;

    @Column(name = "FAX", length = 15)
    private String fax;

    @Column(name = "ADR1", length = 30)
    private String adr1;

    @Column(name = "ADR2", length = 30)
    private String adr2;

    @Column(name = "CODPOS", length = 5)
    private String codpos;

    @Column(name = "VILLE", length = 30)
    private String ville;

    @Column(name = "CODPAYS")
    private Integer codpays;

    @Column(name = "GUICHETORG", length = 3)
    private String guichetorg;

    @Column(name = "CLE", length = 1)
    private String cle;

    @Column(name = "GUICHETPMT", length = 5)
    private String guichetpmt;

    @Column(name = "EMAIL", length = 45)
    private String email;

    @Column(name = "DATNAIS_REGIME", length = 6)
    private String datnaisRegime;

    @Column(name = "MODIFICATEUR")
    private Integer modificateur;

    @Column(name = "DECES")
    private LocalDate deces;

    @Column(name = "N_INSEE", length = 20)
    private String nInsee;

    @Column(name = "REGIME2", length = 2)
    private String regime2;

    @Column(name = "CAISSE2", length = 3)
    private String caisse2;

    @Column(name = "GUICHETORG2", length = 3)
    private String guichetorg2;

    @Column(name = "MATORG2", length = 20)
    private String matorg2;

    @Column(name = "CLESS2")
    private Integer cless2;

    @Column(name = "LIEUNAIS", length = 30)
    private String lieunais;

    @Column(name = "CODPAYSNAIS")
    private Integer codpaysnais;

    @Column(name = "CODDEPNAIS", length = 2)
    private String coddepnais;

    @Column(name = "CODCOMNAIS", length = 5)
    private String codcomnais;
}