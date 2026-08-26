package com.arthus.entitys.enums;

import java.util.Arrays;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum MotifFinEnum implements CodeLibelle {

    CREATION(1, "Création"),
    REPRISE_DU_TRAVAIL(2, "Reprise du travail"),
    ABSENCE_DE_JUSTIFICATIFS(3, "Absence de justificatifs"),
    DECES(4, "Décès"),
    RETRAITE(5, "Retraite"),
    DECISION_ASSUREUR(6, "Décision Assureur"),
    MISE_EN_INVALIDITE(7, "Mise en invalidite"),
    CONGE_MATERNITE(8, "Congé Maternité"),
    CONGE_PARENTAL(9, "Congé parental"),
    ERREUR_DE_SAISIE(10, "Erreur de saisie"),
    DECISION_SOCIETE(11, "Décision Société"),
    ARRET_INFERIEUR_A_LA_FRANCHISE(12, "Arrêt inférieur à la franchise"),
    FIN_INDEMNISATION_IJSS(13, "Fin indemnisation IJSS"),
    PAIEMENT_DU_DOSSIER(14, "Paiement du dossier"),
    CHANGEMENT_DE_PATHOLOGIE(15, "Changement de pathologie"),
    MI_TEMPS_THERAPEUTIQUE_NON_INDEMNISE(16, "Mi-temps thérap. non indemnisé"),
    CONTRAT_RESILIE(17, "Contrat résilié"),
    PRESTATION_NULLE(18, "Prestation nulle"),
    RECHUTE(19, "Rechute"),
    DOSSIER_CONTROLE(20, "Dossier controlé"),
    REOUVERTURE_DU_DOSSIER(21, "Réouverture du dossier"),
    GEREP_N_EST_PLUS_COURTIER(22, "GEREP n'est plus courtier"),
    RUPTURE_CONTRAT_DE_TRAVAIL(23, "Rupture contrat de travail"),
    ASSURE_EN_ANI(24, "Assuré(e) en ANI"),
    AUTRE(25, "Autre..."),
    DEMANDE_EXPERTISE_MC(26, "Demande expertise MC"),
    DEMANDE_EXPERTISE_ASSUREUR(27, "Demande expertise Assureur"),
    RETOUR_EXPERTISE_MC(28, "Retour d’expertise MC"),
    RETOUR_EXPERTISE_ASSUREUR(29, "Retour d’expertise Assureur"),
    SUIVI_ASSUREUR(30, "Suivi Assureur"),
    CREATION_VIA_EXTRANET(31, "Création via Extranet");

    private final Integer code;
    private final String libelleDefaut;

    private static final Map<Integer, MotifFinEnum> PAR_CODE =
            Arrays.stream(values())
                  .collect(Collectors.toUnmodifiableMap(MotifFinEnum::getCode, Function.identity()));

    public static MotifFinEnum fromCode(Integer code) {
        if (code == null) {
            return null;
        }
        MotifFinEnum motif = PAR_CODE.get(code);
        if (motif == null) {
            throw new IllegalArgumentException("Code motif de fin inconnu : " + code);
        }
        return motif;
    }
}