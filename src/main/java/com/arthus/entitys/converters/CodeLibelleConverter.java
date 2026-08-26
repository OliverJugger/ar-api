package com.arthus.entitys.converters;

import lombok.*;
import java.util.function.Function;
import com.arthus.entitys.enums.CodeLibelle;
import jakarta.persistence.AttributeConverter;

@RequiredArgsConstructor
public abstract class CodeLibelleConverter<E extends Enum<E> & CodeLibelle>
        implements AttributeConverter<E, Integer> {

    private final Function<Integer, E> resolver;

    @Override
    public Integer convertToDatabaseColumn(E value) {
        return value == null ? null : value.getCode();
    }

    @Override
    public E convertToEntityAttribute(Integer code) {
        return resolver.apply(code);
    }
}