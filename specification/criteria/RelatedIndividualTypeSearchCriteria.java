package com.bdl.epbs_fund_api.specification.criteria;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RelatedIndividualTypeSearchCriteria {
	
	private Boolean isFund;
	private Boolean isSubFund;
	private Boolean isLegalPerson;
    
}