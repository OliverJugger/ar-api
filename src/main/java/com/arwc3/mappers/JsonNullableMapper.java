package com.arwc3.mappers;

import org.mapstruct.Condition;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;
import org.openapitools.jackson.nullable.JsonNullable;

@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.ERROR)
public interface JsonNullableMapper {

    @Condition
    default <T> boolean isNotJsonNullableUndefined(JsonNullable<T> value) {
        return value != null && value.isPresent();
    }

    default <T> JsonNullable<T> toJsonNullable(T value) {
        return JsonNullable.of(value);
    }

    default <T> T fromJsonNullable(JsonNullable<T> value) {
        return value.orElse(null);
    }
    
}
