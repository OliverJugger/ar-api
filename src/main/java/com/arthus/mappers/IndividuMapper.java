package com.arthus.mappers;

import java.util.List;

import org.mapstruct.InjectionStrategy;

import com.arthus.mappers.enums.SexeEnumMapper;
import com.arthus.entitys.Individu;
import com.arthus.generated.model.IndividuDTO;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring",
    uses = { JsonNullableMapper.class, SexeEnumMapper.class },
    injectionStrategy = InjectionStrategy.CONSTRUCTOR,
    unmappedTargetPolicy = ReportingPolicy.ERROR)
public interface IndividuMapper {

    @Mapping(target="nInsee", source="NInsee")
    IndividuDTO toDTO(Individu source);
    List<IndividuDTO> toDTO(List<Individu> source);
}
