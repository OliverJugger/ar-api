package com.arthus.entitys.converters;

import com.arthus.entitys.enums.ContexteEnum;
import jakarta.persistence.Converter;

@Converter
public class ContexteEnumConverter extends CodeLibelleConverter<ContexteEnum> {

    public ContexteEnumConverter() {
        super(ContexteEnum::fromCode);
    }
}