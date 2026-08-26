package com.arthus.mappers.enums;

import com.arthus.entitys.enums.TypeCorrespondantEnum;
import com.arthus.generated.model.TypeCorrespondantEnumDTO;

import org.mapstruct.Mapper;

/*
 * CORRESPONDANT.NAT_CORRES - la qualite du correspondant.
 * Pas CORRESPONDANT.TYPE_CORRES, dont le referentiel reste non identifie.
 */
@Mapper(componentModel = "spring")
public interface TypeCorrespondantEnumMapper {

    TypeCorrespondantEnumDTO toDTO(TypeCorrespondantEnum source);
    TypeCorrespondantEnum toEntity(TypeCorrespondantEnumDTO source);
}
