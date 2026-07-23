package com.arwc3.mappers;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.List;

import org.mapstruct.InjectionStrategy;

import com.arwc3.entitys.Individu;
import com.arwc3.generated.model.IndividuDTO;
import com.arwc3.utils.DateUtils;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;
import org.openapitools.jackson.nullable.JsonNullable;

@Mapper(componentModel = "spring",
    uses = { JsonNullableMapper.class },
    injectionStrategy = InjectionStrategy.CONSTRUCTOR,
    unmappedTargetPolicy = ReportingPolicy.ERROR)
public interface IndividuMapper {

    @Mapping(target="nInsee", source="NInsee")
    IndividuDTO toIndividuDTO(Individu source);
    List<IndividuDTO> toIndividuDTO(List<Individu> source);
}
