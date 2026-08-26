package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.*;

import com.arthus.entitys.enums.TypeCalculEnum;
import com.arthus.entitys.converters.TypeCalculEnumConverter; 

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
    private List<AdhesionContrat> adhesions = new ArrayList<>();

    @Column(name = "NUMGAR_REF")
    private Long numgarRef;

    @Column(name = "REFCIE", length = 30)
    private String refcie;

    @Column(name = "REFCIE_CHAPEAU", length = 25)
    private String refcieChapeau;

    @Column(name = "NUMPROD")
    private Long numprod;
	
	/* ------------------------------------------------------------------ */
    /* Souscripteur : NUMCLI est un NUMINDIV                               */
    /* ------------------------------------------------------------------ */

    @Column(name = "NUMCLI")
    private Long numcli;

    /*
     * Le souscripteur du contrat, en LECTURE SEULE.
     * PK_EXTRACTION_AUTO affiche PK_PERSONNE.F_NOM(contrat.NUMCLI) : F_NOM prend
     * un NUMINDIV, donc NUMCLI pointe bien vers INDIVIDU.
     * La table CLIENT (PK NUMGAR, colonne NUMINDIV) dit la meme chose sous forme
     * de couple contrat/souscripteur et sert au legacy a lister les souscripteurs
     * (V_ENTITE3, V_ENTITE2) ; aucun package du dump ne l'alimente, donc NUMCLI
     * reste la source a privilegier.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMCLI", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu souscripteur;
	
    /* ------------------------------------------------------------------ */
	
	/* ------------------------------------------------------------------ */
    /* Assureur : NUMORG -> PERS_ORGANISME (ROLE = 2) -> INDIVIDU          */
    /* ------------------------------------------------------------------ */

    /* ------------------------------------------------------------------ */
    // Colonne brute NUMORG : proprietaire de la colonne
    @Column(name = "NUMORG")
    private Integer numorg;

    /*
     * L'organisme assureur, en LECTURE SEULE.
     * Requete de reference (PK_WS_WEB_BACK, commentaire "recuperation des
     * informations de l'assureur") :
     *     FROM contrat_ref, pers_organisme, indvs
     *     WHERE pers_organisme.ROLE = 2
     *       AND indvs.numindiv = pers_organisme.numindiv
     *       AND contrat_ref.numorg = pers_organisme.numorg
     *
     * Le filtre ROLE = 2 n'est pas exprimable dans un @JoinColumn : PERS_ORGANISME
     * ayant NUMINDIV pour PK, il ne peut y avoir qu'une ligne par organisme, donc
     * le role est une propriete a verifier (isAssureur()) et non un critere de
     * jointure. A savoir aussi : NUMORG n'a qu'un index NON unique cote base ; la
     * jointure marche parce qu'il est unique dans les faits, mais si tu preferes
     * ne pas prendre le pari, supprime cette association et resous NUMORG par
     * requete.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMORG", referencedColumnName = "NUMORG",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private PersonneOrganisme organismeAssureur;

    /* ------------------------------------------------------------------ */

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
	
    @Convert(converter = TypeCalculEnumConverter.class)
    @Column(name = "TYPE_CALC")
    private TypeCalculEnum typeCalc;

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
