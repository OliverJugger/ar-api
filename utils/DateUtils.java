package com.bdl.epbs_fund_api.utils;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.Date;
import java.util.Objects;
import java.util.Optional;

public class DateUtils {

    private DateUtils() {}

	public static final LocalDate MAX_DATE_AVALOQ = LocalDate.of(9999, 12, 31);

    public static OffsetDateTime toOffsetDateTime(Date date) {
        return date == null ? null : date.toInstant().atOffset(ZoneOffset.UTC);
    }

    public static OffsetDateTime toOffsetDateTime(Instant instant) {
        ZoneOffset zoneOffset = ZoneId.of("Europe/Berlin").getRules().getOffset(instant);
        return instant.atOffset(zoneOffset);
    }

    public static boolean isAfter(LocalDate date1, LocalDate date2) {
        return Objects.nonNull(date1) && Objects.nonNull(date2) && date1.isAfter(date2);
    }
    
    public static LocalDateTime convertToDateTime(LocalDate date) {
        return Optional.ofNullable(date)
                .map(LocalDate::atStartOfDay)
                .orElse(null);
    }

}
