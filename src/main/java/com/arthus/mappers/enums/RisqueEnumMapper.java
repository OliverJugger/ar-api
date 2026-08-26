package com.arthus.mappers.enums;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants;
import org.mapstruct.ValueMapping;

import com.arthus.entitys.enums.RisqueEnum;
import com.arthus.generated.model.RisqueEnumDTO;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface RisqueEnumMapper {

    @ValueMapping(target = "FRAIS_SANTE", source = "FRAIS_DE_SANTE")
    @ValueMapping(target = "INCAPACITE_TRAVAIL", source = "INCAPACITE_DE_TRAVAIL")
    RisqueEnumDTO toDTO(RisqueEnum source);

    @ValueMapping(target = "FRAIS_DE_SANTE", source = "FRAIS_SANTE")
    @ValueMapping(target = "INCAPACITE_DE_TRAVAIL", source = "INCAPACITE_TRAVAIL")
    RisqueEnum toEntity(RisqueEnumDTO source);
}