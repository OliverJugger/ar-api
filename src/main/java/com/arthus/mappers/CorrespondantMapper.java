package com.arthus.mappers;


import java.util.List;
import java.util.Optional;
import com.arthus.entitys.Individu;
import com.arthus.entitys.contextuel.Correspondant;
import com.arthus.generated.model.CorrespondantDTO;
import com.arthus.mappers.enums.TypeCorrespondantEnumMapper;
import com.arthus.mappers.enums.SexeEnumMapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;

/*
 * CORRESPONDANT -> CorrespondantDTO.
 *
 * Ce mapper ne couvre qu'un champ sur quatre, et c'est normal : le DTO expose
 * des libelles, l'entite porte des cles et des associations.
 *
 * nature : le DTO attend une String, pas l'enum. On prend le libelle par defaut
 * de TypeCorrespondantEnum (NAT_CORRES). Si tu preferes le libelle a jour de la
 * table LIBELLE plutot que celui fige dans l'enum, passe ce champ en ignore et
 * laisse le service le resoudre.
 *
 * Pas de JsonNullableMapper en "uses" : aucun champ du DTO n'est nullable.
 */
@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.ERROR,
    uses = { 
		TypeCorrespondantEnumMapper.class, 
		SexeEnumMapper.class 
	})
public interface CorrespondantMapper {

    @Mapping(target = "type", source = "natCorres")
    @Mapping(target = "sexeCorrespondant", source = "correspondant.sexe")
    @Mapping(target = "nomCorrespondant", source = "correspondant", qualifiedByName = "mapNomIndividu")
    @Mapping(target = "sexeInterlocuteur", source = "interlocuteur.sexe")
    @Mapping(target = "nomInterlocuteur", source = "interlocuteur", qualifiedByName = "mapNomIndividu")
    CorrespondantDTO toDTO(Correspondant source);
    List<CorrespondantDTO> toDTO(List<Correspondant> source);

    @Named("mapNomIndividu")
    default String mapNomIndividu(Individu source) {
        if(source == null) return null;
		String prenom = source.getPrenom();
		String nom = source.getNom();
		
		if(prenom == null) return nom;
		return prenom + " " + nom;
    }
}
