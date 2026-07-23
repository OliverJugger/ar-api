package com.bdl.epbs_fund_api.specification.criteria;

import java.time.LocalDate;

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
public class SubFundNetAssetValueSearchCriteria {
  
    private Integer subFundId;
    private LocalDate dateFrom;
    private LocalDate dateTo;
    
}