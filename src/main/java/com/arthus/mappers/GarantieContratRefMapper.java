package com.arthus.mappers;

import java.util.List;
import com.arthus.entitys.GarantieContratRef;
import com.arthus.generated.model.GarantieContratDTO;
import com.arthus.mappers.enums.TypeCalculEnumMapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;

/*
 * GAR_CNTRT_REF -> GarantieContratDTO.
 *
 * dateEffet et dateFin sont des JsonNullable<LocalDate> cote DTO : la methode
 * generique toJsonNullable(T) de JsonNullableMapper suffit, pas besoin de
 * qualifiedByName (celui-ci ne sert qu'aux LocalDateTime -> OffsetDateTime).
 *
 * unmappedTargetPolicy = ERROR : toute propriete du DTO non couverte casse le
 * build. C'est volontaire - un champ oublie se voit a la compilation, pas dans
 * un JSON a null en recette.
 */
@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.ERROR,
    uses = { 
		JsonNullableMapper.class, 
		TypeCalculEnumMapper.class 
	})
public interface GarantieContratRefMapper {

    @Mapping(target = "idGarantie", source = "numfor")
    @Mapping(target = "libelle", source = "libelle")
    @Mapping(target = "dateEffet", source = "datapli")
    @Mapping(target = "dateFin", source = "datper")
    @Mapping(target = "idContrat", source = "numgar")
    @Mapping(target = "numeroReferenceContrat", source = "contratRef.refcie")
    @Mapping(target = "typeCalcul", source = "contratRef.typeCalc")
    @Mapping(target = "valide", source = "valide", qualifiedByName= "mapValide")
    GarantieContratDTO toDTO(GarantieContratRef source);
    List<GarantieContratDTO> toDTO(List<GarantieContratRef> source);
	
	@Named("mapValide")
	default boolean mapValide(String source) {
		return "O".equals(source);
	}
}
