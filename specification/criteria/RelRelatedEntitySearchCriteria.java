package com.bdl.epbs_fund_api.specification.criteria;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import com.bdl.epbs_fund_api.model.RelatedEntityTypeEnumDTO;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RelRelatedEntitySearchCriteria {
	
	private List<String> dataProfileIntlIds;
    private List<Integer> uciEntityIds;
    private Integer legalPersonId;
    private RelatedEntityTypeEnumDTO relatedEntityType;
    private UUID taskUid;
    private String legalPersonName;
    private LocalDate startDateStart;
    private LocalDate startDateEnd;
    private LocalDate endDateStart;
    private LocalDate endDateEnd;
    private LocalDate activeDate;
}