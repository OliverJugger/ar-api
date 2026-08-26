package com.arthus.mappers;

import java.util.Collections;
import java.util.List;

import com.arthus.entitys.DossierSinistre;
import com.arthus.generated.model.DossierSinistreDTO;
import com.arthus.generated.model.DossierSinistreDetailsDTO;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.InjectionStrategy;
import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring",
    uses = { 
        IndividuMapper.class, 
        SinistreMapper.class,
        UtilisateurMapper.class, 
        JsonNullableMapper.class 
    },
    injectionStrategy = InjectionStrategy.CONSTRUCTOR,
    unmappedTargetPolicy = ReportingPolicy.ERROR)
public interface DossierSinistreMapper {

    @Mapping(target="numeroContrats", source=".", qualifiedByName="mapNumeroContrats")
    @Mapping(target="assure", source="assure")  // uses IndividuMapper
    @Mapping(target="sinistres", source="sinistres") // uses SinistreMapper
    @Mapping(target="gestionnaire", source="gestionnaire") // uses UtilisateurMapper
    @Mapping(target="debut", source="debut", qualifiedByName="toOffsetDateTime")
    @Mapping(target="fin", source="fin", qualifiedByName="toOffsetDateTime")
    @Mapping(target="cloture", source="cloture", qualifiedByName="toOffsetDateTime")
    DossierSinistreDetailsDTO toDossierSinistreDetailsDTO(DossierSinistre source);

    @Mapping(target="numeroContrats", source=".", qualifiedByName="mapNumeroContrats")
    @Mapping(target="assure", source="assure")  // uses IndividuMapper
    @Mapping(target="debut", source="debut", qualifiedByName="toOffsetDateTime")
    @Mapping(target="fin", source="fin", qualifiedByName="toOffsetDateTime")
    @Mapping(target="cloture", source="cloture", qualifiedByName="toOffsetDateTime")
    DossierSinistreDTO toDossierSinistreDTO(DossierSinistre source);
    List<DossierSinistreDTO> toDossierSinistreDTO(List<DossierSinistre> source);

    @Named("mapNumeroContrats")
    default List<Long> mapNumeroContrats(DossierSinistre source) {
        return source.getSinistres()
            .stream()
            .flatMap(s -> s.getRepartitions().stream())
            .filter(r -> "O".equals(r.getValide()))
            .map(r -> r.getAdhesionContrat().getNumgar())
            .distinct()
            .toList();
    }
}
