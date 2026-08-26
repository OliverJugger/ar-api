package com.arthus.entitys.enums;

import java.util.Arrays;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ProfilUtilisateurEnum implements CodeLibelleTexte {

    CONSULTATION_ET_PEC("ACC", "Consultation et PEC"),
    RESPONSABLE_PREVOYANCE("RPV", "Responsable prévoyance"),
    ADJOINT("ADJ", "Adjoint"),
    GESTIONNAIRE_SUPPORT("SUPP", "Gestionnaire support"),
    GESTIONNAIRE_AFFILIATIONS("MAJ", "Gestionnaire affiliations"),
    CONSULTATION("COM", "Consultation"),
    GESTIONNAIRE_PREVOYANCE("PREV", "Gestionnaire prévoyance"),
    ADMINISTRATEUR("ADM", "Administrateur"),
    NON_UTILISABLE("CLT", "Non utilisable"),
    GESTIONNAIRE_COTISATIONS("COTI", "Gestionnaire cotisations"),
    COMPTABILITE("CPT", "Comptabilité"),
    GESTIONNAIRE_DECOMPTEUR("DCPT", "Gestionnaire décompteur"),
    CONTROLE_PRESTATIONS("CTRL", "Contrôle prestations"),
    PERSONNEL_SORTI("HS", "Personnel sorti"),
    PLATEFORME_TELEPHONIQUE("PFTL", "Plateforme téléphonique"),
    FRONT_OFFICE("FROF", "Front office"),
    PARAMETRAGE("PARM", "Paramétrage"),
    APPORTEUR("APP", "Apporteur");

    private final String code;
    private final String libelleDefaut;

    private static final Map<String, ProfilUtilisateurEnum> PAR_CODE =
            Arrays.stream(values())
                  .collect(Collectors.toUnmodifiableMap(ProfilUtilisateurEnum::getCode, Function.identity()));

    public static ProfilUtilisateurEnum fromCode(String code) {
        if (code == null) {
            return null;
        }
        ProfilUtilisateurEnum profil = PAR_CODE.get(code.trim());
        if (profil == null) {
            throw new IllegalArgumentException("Code profil utilisateur inconnu : " + code);
        }
        return profil;
    }
}