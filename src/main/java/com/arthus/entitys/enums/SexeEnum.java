package com.arthus.entitys.enums;

import java.util.Arrays;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 1 = M ; 2 = MME
 */
@Getter
@RequiredArgsConstructor
public enum SexeEnum implements CodeLibelle {

    M(1, "Masculin"),
    MME(2, "Féminin");

    private final Integer code;
    private final String libelleDefaut;

    private static final Map<Integer, SexeEnum> PAR_CODE =
            Arrays.stream(values())
                  .collect(Collectors.toUnmodifiableMap(SexeEnum::getCode, Function.identity()));

    public static SexeEnum fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        SexeEnum risque = PAR_CODE.get(code);
        if (risque == null) {
            throw new IllegalArgumentException("Code sexe inconnu : " + code);
        }
        return risque;
    }
}