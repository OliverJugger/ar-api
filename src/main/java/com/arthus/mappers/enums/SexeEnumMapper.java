package com.arthus.mappers.enums;

import com.arthus.entitys.enums.SexeEnum;
import com.arthus.generated.model.SexeEnumDTO;

import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface SexeEnumMapper {

    SexeEnumDTO toDTO(SexeEnum source);
    SexeEnum toEntity(SexeEnumDTO source);
}
