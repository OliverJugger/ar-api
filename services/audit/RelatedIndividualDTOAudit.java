package com.bdl.epbs_fund_api.services.audit;

import com.bdl.epbs_fund_api.model.RelatedIndividualTypeDTO;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@JsonInclude()
@Data
public class RelatedIndividualDTOAudit {

    @JsonProperty(value="related_individual_type")
    private RelatedIndividualTypeDTO relatedIndividualType;

    @JsonProperty(value="job_title")
    private String jobTitle;

    @JsonProperty(value="valid_from")
    private String validFrom;

    @JsonProperty(value="valid_to")
    private String validTo;

    @JsonProperty("percentage_detention")
    private Double percentageDetention;
}
