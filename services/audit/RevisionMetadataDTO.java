package com.bdl.epbs_fund_api.services.audit;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.OffsetDateTime;

@Getter
@Setter
@NoArgsConstructor
public class RevisionMetadataDTO {
    private static final long serialVersionUID = 1L;

    private String type;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private OffsetDateTime date;

    private String username;

    private Integer number;
}

