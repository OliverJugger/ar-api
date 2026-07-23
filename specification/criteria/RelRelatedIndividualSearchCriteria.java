package com.bdl.epbs_fund_api.specification.criteria;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import com.bdl.epbs_fund_api.model.RelatedIndividualCategoryTypeEnumDTO;
import com.bdl.epbs_fund_api.model.RelatedIndividualTypeEnumDTO;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RelRelatedIndividualSearchCriteria {
	
	private List<String> dataProfileIntlIds;
    private Integer uciEntityId;
    private String uciEntityTypeIntlId;
    private RelatedIndividualCategoryTypeEnumDTO relatedIndividualTypeCategory;
    private RelatedIndividualTypeEnumDTO relatedIndividualType;
    private Integer legalPersonId;
    private Integer naturalPersonId;
    private UUID taskUuid;
    private String naturalPersonNameContains;
    private LocalDate startDateStart;
    private LocalDate startDateEnd;
    private LocalDate endDateStart;
    private LocalDate endDateEnd;
    private LocalDate activeDate;
    
}