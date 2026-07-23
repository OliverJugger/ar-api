package com.bdl.epbs_fund_api.specification.criteria;

import java.io.Serializable;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@EqualsAndHashCode
@Builder
public class SubFundSearchCriteria implements Serializable {
	private static final long serialVersionUID = 8717583225973676151L;
	
	private List<String> dataProfileIntlIds;
    private List<Integer> subFundIds;
    private Integer fundId;
    private Integer projectId;
    private String name;
    
}