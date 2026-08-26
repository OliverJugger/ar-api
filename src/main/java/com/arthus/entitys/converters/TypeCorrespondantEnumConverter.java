package com.arthus.entitys.converters;

import com.arthus.entitys.enums.TypeCorrespondantEnum;
import jakarta.persistence.Converter;

@Converter
public class TypeCorrespondantEnumConverter extends CodeLibelleConverter<TypeCorrespondantEnum> {

    public TypeCorrespondantEnumConverter() {
        super(TypeCorrespondantEnum::fromCode);
    }
}
