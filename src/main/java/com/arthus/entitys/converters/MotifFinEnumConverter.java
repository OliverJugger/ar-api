package com.arthus.entitys.converters;

import com.arthus.entitys.enums.MotifFinEnum;
import jakarta.persistence.Converter;

@Converter
public class MotifFinEnumConverter extends CodeLibelleConverter<MotifFinEnum> {

    public MotifFinEnumConverter() {
        super(MotifFinEnum::fromCode);
    }
}