package com.bdl.epbs_fund_api.specification.criteria;

import java.io.Serializable;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class ProjectSearchCriteria implements Serializable {
	private static final long serialVersionUID = 1L;

    private Integer projectId;
    private Integer subFundId;
    
}