package com.arthus.mappers.enums;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants;
import org.mapstruct.ValueMapping;

import com.arthus.entitys.enums.MotifFinEnum;
import com.arthus.generated.model.MotifFinEnumDTO;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface MotifFinEnumMapper {

    @ValueMapping(target = "REPRISE_TRAVAIL", source = "REPRISE_DU_TRAVAIL")
    @ValueMapping(target = "ABSENCE_JUSTIFICATIFS", source = "ABSENCE_DE_JUSTIFICATIFS")
    @ValueMapping(target = "MISE_INVALIDITE", source = "MISE_EN_INVALIDITE")
    @ValueMapping(target = "ERREUR_SAISIE", source = "ERREUR_DE_SAISIE")
    @ValueMapping(target = "ARRET_INFERIEUR_A_FRANCHISE", source = "ARRET_INFERIEUR_A_LA_FRANCHISE")
    @ValueMapping(target = "PAIEMENT_DOSSIER", source = "PAIEMENT_DU_DOSSIER")
    @ValueMapping(target = "CHANGEMENT_PATHOLOGIE", source = "CHANGEMENT_DE_PATHOLOGIE")
    @ValueMapping(target = "MI_TEMPS_THERAP_NON_INDEMNISE", source = "MI_TEMPS_THERAPEUTIQUE_NON_INDEMNISE")
    @ValueMapping(target = "REOUVERTURE_DOSSIER", source = "REOUVERTURE_DU_DOSSIER")
    @ValueMapping(target = "PLUS_COURTIER", source = "GEREP_N_EST_PLUS_COURTIER")
    @ValueMapping(target = "RUPTURE_CONTRAT_TRAVAIL", source = "RUPTURE_CONTRAT_DE_TRAVAIL")
    @ValueMapping(target = "ASSURE_E_ANI", source = "ASSURE_EN_ANI")
    MotifFinEnumDTO toDTO(MotifFinEnum source);

    @ValueMapping(target = "REPRISE_DU_TRAVAIL", source = "REPRISE_TRAVAIL")
    @ValueMapping(target = "ABSENCE_DE_JUSTIFICATIFS", source = "ABSENCE_JUSTIFICATIFS")
    @ValueMapping(target = "MISE_EN_INVALIDITE", source = "MISE_INVALIDITE")
    @ValueMapping(target = "ERREUR_DE_SAISIE", source = "ERREUR_SAISIE")
    @ValueMapping(target = "ARRET_INFERIEUR_A_LA_FRANCHISE", source = "ARRET_INFERIEUR_A_FRANCHISE")
    @ValueMapping(target = "PAIEMENT_DU_DOSSIER", source = "PAIEMENT_DOSSIER")
    @ValueMapping(target = "CHANGEMENT_DE_PATHOLOGIE", source = "CHANGEMENT_PATHOLOGIE")
    @ValueMapping(target = "MI_TEMPS_THERAPEUTIQUE_NON_INDEMNISE", source = "MI_TEMPS_THERAP_NON_INDEMNISE")
    @ValueMapping(target = "REOUVERTURE_DU_DOSSIER", source = "REOUVERTURE_DOSSIER")
    @ValueMapping(target = "GEREP_N_EST_PLUS_COURTIER", source = "PLUS_COURTIER")
    @ValueMapping(target = "RUPTURE_CONTRAT_DE_TRAVAIL", source = "RUPTURE_CONTRAT_TRAVAIL")
    @ValueMapping(target = "ASSURE_EN_ANI", source = "ASSURE_E_ANI")
    MotifFinEnum toEntity(MotifFinEnumDTO source);
}