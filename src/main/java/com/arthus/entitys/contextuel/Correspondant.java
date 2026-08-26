package com.arthus.entitys.contextuel;

import jakarta.persistence.*;
import lombok.*;

import com.arthus.entitys.Individu;
import com.arthus.entitys.enums.ContexteEnum;
import com.arthus.entitys.converters.ContexteEnumConverter;
import com.arthus.entitys.enums.TypeCorrespondantEnum;
import com.arthus.entitys.converters.TypeCorrespondantEnumConverter;

import java.time.LocalDateTime;

/*
 * Table ARTHUS.CORRESPONDANT - les correspondants saisis a la main sur un objet
 * metier. PK = ID_CORRES, alimentee par la sequence ARTHUS.ID_CORRES.
 *
 * La table est generique : elle ne connait pas le sinistre, elle connait un
 * couple (CONTEXTE, ENTITE).
 *   SINISTRE_PREVOYANCE (15) -> ENTITE = le NOSIN
 *   CONTRAT (2)              -> ENTITE = le NUMGAR
 * Referentiel LIBELLE mnemo 'CONTE', porte par ContexteEnum.
 *
 * Pas d'association JPA vers SinistrePrevoyance : voir EntiteContextuelle pour
 * les trois raisons. La conversion du NOSIN est dans CleContexte, l'acces dans
 * CorrespondantService.
 *
 * Exemple d'insertion de reference (P_REPRISE_SIN_PREV_XEROX, creation du
 * correspondant beneficiaire) :
 *   INSERT INTO CORRESPONDANT (CONTEXTE, ENTITE, NUMCORRES, TYPE_CORRES, ...,
 *                              ID_CORRES, NAT_CORRES, INTERLOCUTEUR)
 *   SELECT 15, v_nosin, v_numindiv, 6, ..., ID_CORRES.nextval, 4, v_numindiv
 *   FROM DUAL WHERE NOT EXISTS (SELECT ... FROM correspondant
 *                                WHERE contexte = 15 AND nat_corres = 4
 *                                  AND numcorres = v_numindiv AND entite = v_nosin);
 * L'unicite metier porte donc sur (CONTEXTE, ENTITE, NAT_CORRES, NUMCORRES) -
 * elle n'est garantie par aucune contrainte, c'est au code de la tenir.
 */
@Entity
@Table(name = "CORRESPONDANT", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Correspondant implements EntiteContextuelle {

    @Id
    @Column(name = "ID_CORRES", nullable = false)
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seqIdCorres")
    @SequenceGenerator(name = "seqIdCorres", schema = "ARTHUS",
                       sequenceName = "ID_CORRES", allocationSize = 1)
    private Long idCorres;

    // Referentiel LIBELLE 'CONTE'
    @Convert(converter = ContexteEnumConverter.class)
    @Column(name = "CONTEXTE")
    private ContexteEnum contexte;

    // Cle de l'objet vise, interpretee selon CONTEXTE. Pour SINISTRE_PREVOYANCE : TO_NUMBER(NOSIN)
    @Column(name = "ENTITE")
    private Long entite;

    /* --- Colonne brute NUMCORRES : le correspondant, un NUMINDIV --- */
    @Column(name = "NUMCORRES")
    private Long numcorres;

    // Meme colonne, vue comme association, en LECTURE SEULE
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMCORRES", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu correspondant;

    /*
     * Personne physique a contacter chez le correspondant (souvent egale a
     * NUMCORRES quand celui-ci est deja une personne physique).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "INTERLOCUTEUR", referencedColumnName = "NUMINDIV")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu interlocuteur;

    /*
     * ATTENTION : ce n'est PAS la qualite du correspondant, malgre son nom - ce
     * role revient a NAT_CORRES (voir plus bas). Dans les deux inserts de
     * reference, TYPE_CORRES vaut 6 pour un correspondant beneficiaire
     * (P_REPRISE_SIN_PREV*) et 5 pour un correspondant assure
     * (PK_WS_WEB_MAJ_BACK, M0006706), soit un decalage systematique de +2 par
     * rapport a NAT_CORRES. PK_PREV_GESTIP filtre d'ailleurs sur type_corres = 6
     * pour retrouver les beneficiaires. Referentiel non identifie dans le dump :
     * laisse en Integer tant qu'un SELECT sur LIBELLE ne l'a pas tranche.
     */
    @Column(name = "TYPE_CORRES")
    private Integer typeCorres;

    /*
     * La qualite du correspondant : souscripteur, assure, beneficiaire, tuteur...
     * C'est bien cette colonne que decrit TypeCorrespondantEnum, pas TYPE_CORRES.
     *
     * Le legacy la calcule a partir du type de destinataire de reglement, via la
     * colonne SENS du referentiel et non son code :
     *     NAT_CORRES = pk_libelle.F_LIB_SENS_BY_MNEMO('RGLTDEST', a_type_dest)
     * (PK_PREV). Valeurs vues en dur : 1, 2, 3, 4 et 6 (V_BENE_JUSTIF_SIN,
     * P_REPRISE_SIN_PREV*, PK_WS_WEB_MAJ_BACK).
     */
    @Convert(converter = TypeCorrespondantEnumConverter.class)
    @Column(name = "NAT_CORRES")
    private TypeCorrespondantEnum natCorres;

    // 'O' = correspondant par defaut du sinistre (la * de V_CORRES)
    @Column(name = "DEFAUT_SNTR", length = 1)
    private String defautSntr;

    // Destinataire par defaut des demandes de pieces justificatives, cote assure
    @Column(name = "DEFAUT_PJ_ASSU", length = 1)
    private String defautPjAssu;

    // Idem cote beneficiaire
    @Column(name = "DEFAUT_PJ_BENE", length = 1)
    private String defautPjBene;

    // Destinataire par defaut du reglement beneficiaire
    @Column(name = "DEFAUT_RGLT_BENE", length = 1)
    private String defautRgltBene;

    @Column(name = "CREATION")
    private LocalDateTime creation;

    @Column(name = "CREATEUR")
    private Integer createur;

    @Column(name = "MODIFICATION")
    private LocalDateTime modification;

    @Column(name = "MODIFICATEUR")
    private Integer modificateur;
}
