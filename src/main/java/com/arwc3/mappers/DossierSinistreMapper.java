package com.arwc3.mappers;

import java.util.List;
import com.arwc3.entitys.DossierSinistre;
import com.arwc3.generated.model.DossierSinistreDTO;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface DossierSinistreMapper {
    DossierSinistreDTO toDossierSinistreDTO(DossierSinistre source);
    List<DossierSinistreDTO> toDossierSinistreDTO(List<DossierSinistre> source);
}
