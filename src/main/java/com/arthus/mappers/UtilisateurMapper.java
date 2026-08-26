package com.arthus.mappers;

import java.util.Collections;
import java.util.List;

import com.arthus.entitys.Utilisateur;
import com.arthus.generated.model.UtilisateurDTO;
import com.arthus.mappers.enums.ProfilUtilisateurEnumMapper;
import com.arthus.mappers.enums.MotifFinEnumMapper;
import com.arthus.mappers.enums.RisqueEnumMapper;
import org.openapitools.jackson.nullable.JsonNullable;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.InjectionStrategy;
import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring",
    uses = { ProfilUtilisateurEnumMapper.class },
    injectionStrategy = InjectionStrategy.CONSTRUCTOR,
    unmappedTargetPolicy = ReportingPolicy.ERROR)
public interface UtilisateurMapper {

    @Mapping(target = "id", source = "numUtil")
    UtilisateurDTO toDTO(Utilisateur source);

    default JsonNullable<UtilisateurDTO> toJsonNullableDto(Utilisateur source) {
        return source == null
                ? JsonNullable.undefined()
                : JsonNullable.of(toDTO(source));
    }
    
}
