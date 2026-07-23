package com.bdl.epbs_fund_api.specification.criteria;

import java.io.Serializable;
import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FundSearchCriteria implements Serializable {
    private String name;
	private List<String> dataProfileIntlIds;
    private List<Integer> fundIds;
}
