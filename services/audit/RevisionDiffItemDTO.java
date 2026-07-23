package com.bdl.epbs_fund_api.services.audit;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class RevisionDiffItemDTO {

    @JsonProperty("field_name")
    private String fieldName;

    @JsonProperty("revision_values")
    private List<RevisionValueDTO> revisionValues;
}
