package com.arthus.mappers.enums;

import com.arthus.entitys.enums.TypeCalculEnum;
import com.arthus.generated.model.TypeCalculEnumDTO;

import org.mapstruct.Mapper;

/*
 * REPARTITION.TYPE_CALC / GAR_PREV.TYPE_CALC (mnemo TCALC).
 * A ne pas confondre avec CONTRAT_REF.TYPE_CALC, qui porte le mnemo TYPC et un
 * tout autre referentiel : le niveau de calcul des cotisations.
 */
@Mapper(componentModel = "spring")
public interface TypeCalculEnumMapper {

    TypeCalculEnumDTO toDTO(TypeCalculEnum source);

    TypeCalculEnum toEntity(TypeCalculEnumDTO source);
}
