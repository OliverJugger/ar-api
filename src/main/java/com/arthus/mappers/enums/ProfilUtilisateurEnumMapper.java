package com.arthus.mappers.enums;

import com.arthus.entitys.enums.ProfilUtilisateurEnum;
import com.arthus.generated.model.ProfilUtilisateurEnumDTO;

import org.mapstruct.Mapper;
import org.mapstruct.ValueMapping;

@Mapper(componentModel = "spring")
public interface ProfilUtilisateurEnumMapper {

    @ValueMapping(target = "CONSULTATION_ET_PEC", source = "CONSULTATION_ET_PEC")
    @ValueMapping(target = "RESPONSABLE_PREVOYANCE", source = "RESPONSABLE_PREVOYANCE")
    @ValueMapping(target = "ADJOINT", source = "ADJOINT")
    @ValueMapping(target = "GESTIONNAIRE_SUPPORT", source = "GESTIONNAIRE_SUPPORT")
    @ValueMapping(target = "GESTIONNAIRE_AFFILIATIONS", source = "GESTIONNAIRE_AFFILIATIONS")
    @ValueMapping(target = "CONSULTATION", source = "CONSULTATION")
    @ValueMapping(target = "GESTIONNAIRE_PREVOYANCE", source = "GESTIONNAIRE_PREVOYANCE")
    @ValueMapping(target = "ADMINISTRATEUR", source = "ADMINISTRATEUR")
    @ValueMapping(target = "NON_UTILISABLE", source = "NON_UTILISABLE")
    @ValueMapping(target = "GESTIONNAIRE_COTISATIONS", source = "GESTIONNAIRE_COTISATIONS")
    @ValueMapping(target = "COMPTABILITE", source = "COMPTABILITE")
    @ValueMapping(target = "GESTIONNAIRE_DECOMPTEUR", source = "GESTIONNAIRE_DECOMPTEUR")
    @ValueMapping(target = "CONTROLE_PRESTATIONS", source = "CONTROLE_PRESTATIONS")
    @ValueMapping(target = "PERSONNEL_SORTI", source = "PERSONNEL_SORTI")
    @ValueMapping(target = "PLATEFORME_TELEPHONIQUE", source = "PLATEFORME_TELEPHONIQUE")
    @ValueMapping(target = "FRONT_OFFICE", source = "FRONT_OFFICE")
    @ValueMapping(target = "PARAMETRAGE", source = "PARAMETRAGE")
    @ValueMapping(target = "APPORTEUR", source = "APPORTEUR")
    ProfilUtilisateurEnumDTO toDTO(ProfilUtilisateurEnum source);
}