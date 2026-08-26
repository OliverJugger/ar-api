package com.arthus.entitys.converters;

import com.arthus.entitys.enums.RisqueEnum;
import jakarta.persistence.Converter;

@Converter
public class RisqueEnumConverter extends CodeLibelleConverter<RisqueEnum> {

    public RisqueEnumConverter() {
        super(RisqueEnum::fromCode);
    }
}