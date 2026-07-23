package com.bdl.epbs_fund_api.specification.criteria;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RelatedEntityTypeSearchCriteria {
	
	private Boolean isFund;
	private Boolean isSubFund;
	private Boolean isLegalPerson;
	private Boolean isOnboarding;
	private Boolean isDelegation;
	private Boolean isAdvisedBy;
	private Boolean isSegment;
	private Boolean isAvaloq;
    
}