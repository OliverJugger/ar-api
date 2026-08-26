package com.arthus.entitys.enums;

import java.util.Arrays;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/*
 * TypeCalculEnum - mode de calcul de la prestation, porte par
 * REPARTITION.TYPE_CALC (et par GAR_PREV.TYPE_CALC, meme referentiel).
 *
 * ATTENTION, homonymie : CONTRAT_REF.TYPE_CALC porte un TOUT AUTRE referentiel,
 * celui du niveau de calcul des cotisations, decode avec le mnemo 'TYPC'
 * (PK_AF10 l'aliase cot_niveau_calcul, PK_TEXTE et charge_contrat l'affichent via
 * f_lib('TYPC', ...)). Ne pas brancher cet enum sur ContratRef.
 *
 * Le mnemo de CE referentiel-ci n'apparait nulle part dans le dump : aucun
 * f_lib() n'est applique a repartition.type_calc ni a gar_prev.type_calc, le
 * legacy testant les codes en dur. Les usages observes confirment les valeurs :
 *   pk_arthusora exclut type_calc != 3 des traitements periodiques (le capital
 *   unique n'a pas de terme a echoir), et maj_gar_prev decode 1, 2 et 3 pour
 *   determiner le regime fiscal de la garantie.
 * A confirmer par un SELECT sur LIBELLE avant de renseigner x-legacy-mnemo.
 */
@Getter
@RequiredArgsConstructor
public enum TypeCalculEnum implements CodeLibelle {

    SUR_ARRETS(1, "Sur arrêts"),
    PERIODIQUE(2, "Périodique"),
    UNIQUE(3, "Unique");

    private final Integer code;
    private final String libelleDefaut;

    private static final Map<Integer, TypeCalculEnum> PAR_CODE =
            Arrays.stream(values())
                  .collect(Collectors.toUnmodifiableMap(TypeCalculEnum::getCode, Function.identity()));

    public static TypeCalculEnum fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        TypeCalculEnum typeCalcul = PAR_CODE.get(code);
        if (typeCalcul == null) {
            throw new IllegalArgumentException("Code type de calcul inconnu : " + code);
        }
        return typeCalcul;
    }
}
