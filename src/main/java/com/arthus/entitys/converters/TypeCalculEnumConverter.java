package com.arthus.entitys.converters;

import com.arthus.entitys.enums.TypeCalculEnum;
import jakarta.persistence.Converter;

@Converter
public class TypeCalculEnumConverter extends CodeLibelleConverter<TypeCalculEnum> {

    public TypeCalculEnumConverter() {
        super(TypeCalculEnum::fromCode);
    }
}
