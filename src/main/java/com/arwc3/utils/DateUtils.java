package com.arwc3.utils;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.Optional;

import lombok.experimental.UtilityClass;

@UtilityClass
public class DateUtils {

    public static OffsetDateTime toOffsetDateTime(LocalDateTime date) {
        return Optional.ofNullable(date)
            .map(d -> d.atZone(ZoneId.of("Europe/Luxembourg")).toOffsetDateTime())
            .orElse(null);
    }
}
