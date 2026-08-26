package com.arthus.entitys.enums;

import java.util.Arrays;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/*
 * SELECT * FROM LIBELLE l WHERE MNEMO='HISTO_SITU'
 * EtatSinistrePrevoyanceEnum
 *
 * Etat porte par HISTO_SNTR_PREV.ETAT. Le legacy l'affiche via
 * PK_LIBELLE.F_LIB('HISTO_SITU', histo.etat) et teste les deux codes en dur :
 * PK_PREV insere ETAT=2 pour fermer un sinistre, PK_PRDG_FONCT lit ETAT=1 pour
 * l'ouverture et ETAT=2 pour la fermeture.
 */
@Getter
@RequiredArgsConstructor
public enum EtatSinistrePrevoyanceEnum implements CodeLibelle {

    EN_COURS(1, "En cours"),
    FERME(2, "Fermé");

    private final Integer code;
    private final String libelleDefaut;

    private static final Map<Integer, EtatSinistrePrevoyanceEnum> PAR_CODE =
            Arrays.stream(values())
                  .collect(Collectors.toUnmodifiableMap(EtatSinistrePrevoyanceEnum::getCode, Function.identity()));

    public static EtatSinistrePrevoyanceEnum fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        EtatSinistrePrevoyanceEnum etat = PAR_CODE.get(code);
        if (etat == null) {
            throw new IllegalArgumentException("Code etat de sinistre prevoyance inconnu : " + code);
        }
        return etat;
    }
}
