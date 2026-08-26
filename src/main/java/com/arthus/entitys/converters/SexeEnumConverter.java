package com.arthus.entitys.converters;

import com.arthus.entitys.enums.SexeEnum;
import jakarta.persistence.Converter;

@Converter
public class SexeEnumConverter extends CodeLibelleConverter<SexeEnum> {

    public SexeEnumConverter() {
        super(SexeEnum::fromCode);
    }
}
