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
public class ShareClassNetAssetValueSearchCriteria {
  
    private Integer shareClassId;
    private LocalDate dateFrom;
    private LocalDate dateTo;
    
}