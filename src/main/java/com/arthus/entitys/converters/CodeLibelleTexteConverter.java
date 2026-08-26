package com.arthus.entitys.converters;

import java.util.function.Function;
import com.arthus.entitys.enums.CodeLibelleTexte;

import jakarta.persistence.AttributeConverter;

public abstract class CodeLibelleTexteConverter<E extends Enum<E> & CodeLibelleTexte>
        implements AttributeConverter<E, String> {

    private final Function<String, E> resolver;

    protected CodeLibelleTexteConverter(Function<String, E> resolver) {
        this.resolver = resolver;
    }

    @Override
    public String convertToDatabaseColumn(E value) {
        return value == null ? null : value.getCode();
    }

    @Override
    public E convertToEntityAttribute(String code) {
        return resolver.apply(code);
    }
}