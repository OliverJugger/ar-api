package com.arthus.entitys.contextuel;

import jakarta.persistence.*;
import lombok.*;

import com.arthus.entitys.Individu;
import com.arthus.entitys.Utilisateur;
import com.arthus.entitys.enums.ContexteEnum;
import com.arthus.entitys.converters.ContexteEnumConverter;

import java.time.LocalDateTime;

/*
 * Table ARTHUS.RAPPEL - "TABLE GESTION DES RAPPELS" (remarque de la table).
 * Identifiant IDRAPPEL, alimente par la sequence ARTHUS.IDRAPPEL.
 *
 * ATTENTION : la table n'a AUCUNE cle primaire declaree en base, et IDX_RAPPEL1
 * sur IDRAPPEL n'est pas unique. On le prend comme @Id parce que c'est
 * l'identifiant fonctionnel et qu'il vient d'une sequence, mais rien ne garantit
 * son unicite cote base - un doublon donnerait des resultats incoherents cote
 * Hibernate (cache de premier niveau). Un
 *   SELECT idrappel, COUNT(*) FROM rappel GROUP BY idrappel HAVING COUNT(*) > 1
 * confirme ou infirme le pari.
 *
 * Meme mecanique generique que CORRESPONDANT et PIECES : les remarques de colonnes
 * le disent explicitement - CONTEXTE = "DOMAINE(SANTE, PREVOYANCE, COTIS, ETC)",
 * ENTITE = "CLEF FONCTIONNELLE(EXEMPLE:NUMERO DE SINISTRE)".
 * PK_WS_WEB_MAJ_BACK bascule un rappel en CONTEXTE = 16 avec le commentaire
 * "pour dossier sinistre prevoy", ENTITE = le nosin.
 *
 * ETAT, TYPE et ORIGINE ne sont pas typables depuis le dump : aucun mnemo LIBELLE
 * ne leur est associe dans le code fourni. Laisses en Integer volontairement.
 */
@Entity
@Table(name = "RAPPEL", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Rappel implements EntiteContextuelle {

    @Id
    @Column(name = "IDRAPPEL", nullable = false)
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seqIdRappel")
    @SequenceGenerator(name = "seqIdRappel", schema = "ARTHUS",
                       sequenceName = "IDRAPPEL", allocationSize = 1)
    private Long idrappel;

    // Referentiel LIBELLE 'CONTE'
    @Convert(converter = ContexteEnumConverter.class)
    @Column(name = "CONTEXTE")
    private ContexteEnum contexte;

    // "CLEF FONCTIONNELLE(EXEMPLE:NUMERO DE SINISTRE)"
    @Column(name = "ENTITE")
    private Long entite;

    @Column(name = "TYPE")
    private Integer type;

    @Column(name = "ORIGINE")
    private Integer origine;

    @Column(name = "ETAT")
    private Integer etat;

    @Column(name = "REFERENCE", length = 50)
    private String reference;

    @Column(name = "COMMENTAIRE", length = 1500)
    private String commentaire;

    /* --- Personnes concernees --- */

    @Column(name = "NUMASSU")
    private Long numassu;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMASSU", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu assure;

    @Column(name = "NUMBENE")
    private Long numbene;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMBENE", referencedColumnName = "NUMINDIV",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Individu beneficiaire;

    // "Numero de la societe concernee par le rappel, peut etre null suivant le contexte"
    @Column(name = "NUMCLI")
    private Long numcli;

    /* --- Suivi --- */

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "RESPONSABLE", referencedColumnName = "NUMUTIL",
                insertable = false, updatable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Utilisateur responsableUtilisateur;

    @Column(name = "RESPONSABLE")
    private Integer responsable;

    // FK vers GEST_RAPPEL (table non mappee a ce stade)
    @Column(name = "IDGESTRAPPEL")
    private Long idgestrappel;

    @Column(name = "DATEEFFET")
    private LocalDateTime dateeffet;

    @Column(name = "REVISION")
    private LocalDateTime revision;

    @Column(name = "CODE_ERR")
    private Integer codeErr;

    @Column(name = "CREATION")
    private LocalDateTime creation;

    @Column(name = "CREATEUR")
    private Integer createur;

    @Column(name = "MAJ")
    private LocalDateTime maj;

    @Column(name = "MODIFICATEUR")
    private Integer modificateur;
}
