package com.arthus.entitys.enums;

import java.util.Arrays;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/*
 * TypeCorrespondantEnum - la qualite du correspondant : qui il est vis-a-vis de
 * l'objet vise (souscripteur, assure, beneficiaire...).
 *
 * A PORTER SUR CORRESPONDANT.NAT_CORRES, PAS SUR TYPE_CORRES. Les inserts du
 * legacy le montrent : P_REPRISE_SIN_PREV cree le "correspondant bene" avec
 * NAT_CORRES = 4, et PK_WS_WEB_MAJ_BACK (M0006706) cree celui de l'assure avec
 * NAT_CORRES = 3 - soit exactement BENEFICIAIRE(4) et ASSURE(3) de cette liste.
 * TYPE_CORRES vaut 6 et 5 dans ces memes inserts, ce qui donnerait "Medecin" et
 * "Tuteur" : ce n'est donc pas le meme referentiel. Voir le commentaire de
 * TYPE_CORRES dans l'entite Correspondant.
 *
 * NAT_CORRES est derive du type de destinataire de reglement, mais par la colonne
 * SENS et non par le code : PK_PREV ecrit
 *     NAT_CORRES = pk_libelle.F_LIB_SENS_BY_MNEMO('RGLTDEST', a_type_dest)
 * ou a_type_dest est le TYPE_DEST de REPARTITION_BENE (1=BEN, 2=ENT, 3=ASS,
 * 8=TUT). Les correspondances observees tiennent : BEN -> BENEFICIAIRE,
 * ASS -> ASSURE, TUT -> TUTEUR.
 */
@Getter
@RequiredArgsConstructor
public enum TypeCorrespondantEnum implements CodeLibelle {

    SOUSCRIPTEUR(1, "Souscripteur"),
    ASSUREUR(2, "Assureur"),
    ASSURE(3, "Assuré"),
    BENEFICIAIRE(4, "Bénéficiaire"),
    TUTEUR(5, "Tuteur"),
    MEDECIN(6, "Médecin"),
    TIERS(7, "Tiers"),
    TRESOR_PUBLIC(8, "Trésor Public");

    private final Integer code;
    private final String libelleDefaut;

    private static final Map<Integer, TypeCorrespondantEnum> PAR_CODE =
            Arrays.stream(values())
                  .collect(Collectors.toUnmodifiableMap(TypeCorrespondantEnum::getCode, Function.identity()));

    public static TypeCorrespondantEnum fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        TypeCorrespondantEnum type = PAR_CODE.get(code);
        if (type == null) {
            throw new IllegalArgumentException("Code type de correspondant inconnu : " + code);
        }
        return type;
    }
}
