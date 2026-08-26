package com.arthus.mappers;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import org.mapstruct.Condition;
import org.mapstruct.Mapper;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;
import org.openapitools.jackson.nullable.JsonNullable;
import com.arthus.utils.DateUtils;

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

    @Named("toOffsetDateTime")
    default JsonNullable<OffsetDateTime> toOffsetDateTime(LocalDateTime source) {
        return JsonNullable.of(DateUtils.toOffsetDateTime(source));
    }
    
}
