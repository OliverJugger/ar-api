package com.arthus.mappers;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.List;

import org.mapstruct.InjectionStrategy;

import com.arthus.entitys.SinistrePrevoyance;
import com.arthus.generated.model.SinistreDTO;
import com.arthus.generated.model.SinistreDetailsDTO;
import com.arthus.utils.DateUtils;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;
import org.openapitools.jackson.nullable.JsonNullable;
import com.arthus.mappers.IndividuMapper;
import com.arthus.mappers.UtilisateurMapper;
import com.arthus.mappers.enums.MotifFinEnumMapper;
import com.arthus.mappers.enums.RisqueEnumMapper;

@Mapper(componentModel = "spring",
    uses = {
		IndividuMapper.class,
        UtilisateurMapper.class,
        MotifFinEnumMapper.class, 
        RisqueEnumMapper.class, 
        JsonNullableMapper.class 
    },
    injectionStrategy = InjectionStrategy.CONSTRUCTOR,
    unmappedTargetPolicy = ReportingPolicy.ERROR)
public interface SinistreMapper {
    
    @Mapping(target="idSinistre", source="nosin")
    @Mapping(target="dateSurvenance", source="survenance", qualifiedByName="toOffsetDateTime")
    @Mapping(target="dateFin", source="fin", qualifiedByName="toOffsetDateTime")
    @Mapping(target="risque", source="risque")
    @Mapping(target="motifFin", source="motif")
    SinistreDTO toDTO(SinistrePrevoyance source);
    List<SinistreDTO> toDTO(List<SinistrePrevoyance> source);
	
	@Mapping(target="idSinistre", source="nosin")
    @Mapping(target="dateSurvenance", source="survenance", qualifiedByName="toOffsetDateTime")
    @Mapping(target="dateFin", source="fin", qualifiedByName="toOffsetDateTime")
    @Mapping(target="risque", source="risque")
    @Mapping(target="motifFin", source="motif")
    @Mapping(target="dateDeclaration", source="declaration", qualifiedByName="toOffsetDateTime")
    @Mapping(target="datePriseEnCharge", source="prischarge", qualifiedByName="toOffsetDateTime")
    @Mapping(target="datePriseEnChargeCalculee", source="priscalc", qualifiedByName="toOffsetDateTime")
    @Mapping(target="gestionnaire", source = "gestionnaire")
    @Mapping(target="assure", source = "dossierSinistre.assure")
    @Mapping(target="garanties", ignore = true)
    @Mapping(target="historique", ignore = true)
    @Mapping(target="beneficiaires", ignore = true)
    @Mapping(target="correspondants", ignore = true)
    SinistreDetailsDTO toDetailsDTO(SinistrePrevoyance source);

}
