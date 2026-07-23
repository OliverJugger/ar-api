package com.arwc3.mappers;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.List;

import org.mapstruct.InjectionStrategy;

import com.arwc3.entitys.DossierSinistre;
import com.arwc3.generated.model.DossierSinistreDTO;
import com.arwc3.utils.DateUtils;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;
import org.openapitools.jackson.nullable.JsonNullable;

@Mapper(componentModel = "spring",
    uses = { IndividuMapper.class, JsonNullableMapper.class },
    injectionStrategy = InjectionStrategy.CONSTRUCTOR,
    unmappedTargetPolicy = ReportingPolicy.ERROR)
public interface DossierSinistreMapper {

    @Mapping(target="individu", source="individu")
    @Mapping(target="debut", source="debut", qualifiedByName="toOffsetDateTime")
    @Mapping(target="fin", source="fin", qualifiedByName="toOffsetDateTime")
    @Mapping(target="cloture", source="cloture", qualifiedByName="toOffsetDateTime")
    @Mapping(target="creation", source="creation", qualifiedByName="toOffsetDateTime")
    @Mapping(target="modification", source="modification", qualifiedByName="toOffsetDateTime")
    DossierSinistreDTO toDossierSinistreDTO(DossierSinistre source);

    List<DossierSinistreDTO> toDossierSinistreDTO(List<DossierSinistre> source);

    @Named("toOffsetDateTime")
    default JsonNullable<OffsetDateTime> toOffsetDateTime(LocalDateTime source) {
        return JsonNullable.of(DateUtils.toOffsetDateTime(source));
    }
}
