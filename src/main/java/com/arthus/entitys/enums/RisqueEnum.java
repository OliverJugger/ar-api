package com.arthus.entitys.enums;

import java.util.Arrays;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * SELECT * FROM LIBELLE l WHERE MNEMO='RISQ'
 * RisqueEnum
 */
@Getter
@RequiredArgsConstructor
public enum RisqueEnum implements CodeLibelle {

    FRAIS_DE_SANTE(1, "Frais de santé"),
    DECES(2, "Décès"),
    INVALIDITE(3, "Invalidité"),
    INCAPACITE_DE_TRAVAIL(4, "Incapacité de travail"),
    RENTE_EDUCATION(5, "Rente éducation"),
    RENTE_CONJOINT(6, "Rente conjoint"),
    DECES_ACCIDENTEL(7, "Décès accidentel"),
    ASSISTANCE(8, "Assistance"),
    INDIVIDUELLE_ACCIDENT(9, "Individuelle accident");

    private final Integer code;
    private final String libelleDefaut;

    private static final Map<Integer, RisqueEnum> PAR_CODE =
            Arrays.stream(values())
                  .collect(Collectors.toUnmodifiableMap(RisqueEnum::getCode, Function.identity()));

    public static RisqueEnum fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        RisqueEnum risque = PAR_CODE.get(code);
        if (risque == null) {
            throw new IllegalArgumentException("Code risque inconnu : " + code);
        }
        return risque;
    }
}