package com.bdl.epbs_fund_api.domain;

import java.time.LocalDate;

import com.bdl.epbs_fund_api.model.RelatedEntityTypeEnumDTO;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RelatedEntityUciV2Search {
	
	private boolean activeOnly;
	private RelatedEntityTypeEnumDTO type;
	private String legalPersonNameContains;
	private Integer segmentId;
	private LocalDate startDateStart;
	private LocalDate startDateEnd;
	private LocalDate endDateStart;
	private LocalDate endDateEnd;
	
}
