package com.arthus.mappers;

import java.util.List; 
import com.arthus.entitys.HistoriqueSinistrePrevoyance;
import com.arthus.generated.model.SinistreLigneHistoriqueDTO;
import com.arthus.mappers.enums.EtatSinistrePrevoyanceEnumMapper;
import com.arthus.mappers.enums.MotifFinEnumMapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.ReportingPolicy;

/*
 * HISTO_SNTR_PREV -> SinistreLigneHistoriqueDTO.
 *
 * dateEffet et dateSaisie sont des JsonNullable<OffsetDateTime> cote DTO alors
 * que l'entite porte des LocalDateTime : c'est le cas ou qualifiedByName est
 * necessaire, la methode generique toJsonNullable(T) ne sachant pas convertir le
 * fuseau. On passe donc par toOffsetDateTime de JsonNullableMapper.
 *
 * Rappel metier : DEBUT est la date d'EFFET de l'etat (et 2e partie de la cle),
 * SAISIE la date de saisie reelle. Les deux sont distinctes, le DTO les expose
 * separement.
 */
@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.ERROR,
    uses = { 
		JsonNullableMapper.class,
        EtatSinistrePrevoyanceEnumMapper.class,
        MotifFinEnumMapper.class
	})
public interface HistoriqueSinistrePrevoyanceMapper {

    @Mapping(target = "dateEffet", source = "debut", qualifiedByName = "toOffsetDateTime")
    @Mapping(target = "dateSaisie", source = "saisie", qualifiedByName = "toOffsetDateTime")
    @Mapping(target = "etat", source = "etat")
    @Mapping(target = "motifFin", source = "motif")
    @Mapping(target = "nomGestionnaire", source = "saisiPar.nom")
    SinistreLigneHistoriqueDTO toDTO(HistoriqueSinistrePrevoyance source);
    List<SinistreLigneHistoriqueDTO> toDTO(List<HistoriqueSinistrePrevoyance> source);

}