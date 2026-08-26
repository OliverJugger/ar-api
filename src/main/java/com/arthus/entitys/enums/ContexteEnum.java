package com.arthus.entitys.enums;

import java.util.Arrays;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/*
 * SELECT * FROM LIBELLE l WHERE MNEMO='CONTE'
 * ContexteEnum
 *
 * Nomme ContexteEnum et non ContexteCorrespondantEnum : le referentiel n'est pas
 * propre aux correspondants, il sert a toutes les tables generiques (CORRESPONDANT,
 * PIECES, RAPPEL, ENVOI).
 *
 * Referentiel des contextes : il dit de quel objet metier parle un couple
 * (CONTEXTE, ENTITE). Il ne sert pas qu'a CORRESPONDANT - PIECES, RAPPEL et
 * ENVOI utilisent le meme decoupage (PK_PRDG_FONCT lit les PIECES avec
 * CONTEXTE = 15 et entite = le nosin, PK_WS_WEB_MAJ_BACK bascule un RAPPEL en
 * CONTEXTE = 16 "pour dossier sinistre prevoy").
 *
 * Les codes 1, 10, 11, 18 et 23 ne sont pas repris ici : ils sont absents du
 * referentiel fourni.
 */
@Getter
@RequiredArgsConstructor
public enum ContexteEnum implements CodeLibelle {

    PERSONNE(0, "Personne"),
    CONTRAT(2, "Contrat"),
    SOUSCRIPTEUR(3, "Souscripteur"),
    ASSURE_PRINCIPAL(4, "Assuré principal"),
    COMPAGNIE(5, "Compagnie"),
    DEVIS_SANTE(6, "Devis Santé"),
    PRODUIT(7, "Produit"),
    INTERMEDIAIRE(8, "Intermédiaire"),
    SOCIETE(9, "Société"),
    AYANT_DROIT(12, "Ayant droit"),
    ADHESION(13, "Adhésion"),
    PROPOSITION(14, "Proposition"),
    SINISTRE_PREVOYANCE(15, "Sinistre prévoyance"),
    DOSSIER_SINISTRE_PREVOYANCE(16, "Dossier sinistre prévoyance"),
    BENEFICIAIRE_SINISTRE_PREVOYANCE(17, "Bénéficiaire sinistre prévoyance"),
    TELETRANSMISSION(19, "Télétransmission"),
    PROSPECT(20, "Prospect"),
    TRAITE(21, "Traité"),
    AVENANT(22, "Avenant"),
    ADHESION_COLLECTIVE(24, "Adhésion collective"),
    GARANTIE(25, "Garantie"),
    PRISE_EN_CHARGE_HOSPITALIERE(26, "Prise en Charge Hospitalière"),
    DOSSIER_SANTE(27, "Dossier santé");

    private final Integer code;
    private final String libelleDefaut;

    private static final Map<Integer, ContexteEnum> PAR_CODE =
            Arrays.stream(values())
                  .collect(Collectors.toUnmodifiableMap(ContexteEnum::getCode, Function.identity()));

    public static ContexteEnum fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        ContexteEnum contexte = PAR_CODE.get(code);
        if (contexte == null) {
            throw new IllegalArgumentException("Code contexte inconnu : " + code);
        }
        return contexte;
    }
}
