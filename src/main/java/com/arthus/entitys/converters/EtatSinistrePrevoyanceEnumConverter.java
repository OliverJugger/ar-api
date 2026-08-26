package com.arthus.entitys.converters;

import com.arthus.entitys.enums.EtatSinistrePrevoyanceEnum;
import jakarta.persistence.Converter;

@Converter
public class EtatSinistrePrevoyanceEnumConverter extends CodeLibelleConverter<EtatSinistrePrevoyanceEnum> {

    public EtatSinistrePrevoyanceEnumConverter() {
        super(EtatSinistrePrevoyanceEnum::fromCode);
    }
}
