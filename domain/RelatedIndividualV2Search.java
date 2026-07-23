package com.bdl.epbs_fund_api.domain;

import java.time.LocalDate;

import com.bdl.epbs_fund_api.model.RelatedIndividualCategoryTypeEnumDTO;
import com.bdl.epbs_fund_api.model.RelatedIndividualTypeEnumDTO;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RelatedIndividualV2Search {
	
	private boolean activeOnly;
	private RelatedIndividualCategoryTypeEnumDTO category;
	private RelatedIndividualTypeEnumDTO type;
	private String naturalPersonNameContains;
	private LocalDate startDateStart;
	private LocalDate startDateEnd;
	private LocalDate endDateStart;
	private LocalDate endDateEnd;
	
}