package com.arthus.mappers.enums;

import com.arthus.entitys.enums.EtatSinistrePrevoyanceEnum;
import com.arthus.generated.model.EtatSinistrePrevoyanceEnumDTO;

import org.mapstruct.Mapper;

/*
 * HISTO_SNTR_PREV.ETAT. Les constantes portent le meme nom des deux cotes,
 * MapStruct les apparie donc automatiquement.
 *
 * L'interet du mapper est ailleurs : MapStruct verifie l'exhaustivite a la
 * COMPILATION. Une valeur ajoutee au contrat OpenAPI sans son equivalent Java
 * (ou l'inverse) casse le build, au lieu de lever une IllegalArgumentException
 * en production. Pour un referentiel qui vit en base, c'est le filet utile.
 */
@Mapper(componentModel = "spring")
public interface EtatSinistrePrevoyanceEnumMapper {

    EtatSinistrePrevoyanceEnumDTO toDTO(EtatSinistrePrevoyanceEnum source);

    EtatSinistrePrevoyanceEnum toEntity(EtatSinistrePrevoyanceEnumDTO source);
}
