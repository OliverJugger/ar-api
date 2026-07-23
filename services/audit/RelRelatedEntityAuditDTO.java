package com.bdl.epbs_fund_api.services.audit;

import java.util.List;

import com.bdl.epbs_fund_api.model.LegalPersonItemDTO;
import com.bdl.epbs_fund_api.model.RelatedEntityTypeDTO;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class RelRelatedEntityAuditDTO {

	@JsonProperty(value="valid_from")
	private String validFrom;

	@JsonProperty(value="valid_to")
	private String validTo;

	@JsonProperty(value="rel_uci_legal_person")
	private LegalPersonItemDTO relUciLegalPerson;

	@JsonProperty(value="related_entity_type")
	private RelatedEntityTypeDTO relatedEntityType;

	@JsonManagedReference
	@JsonProperty(value="rel_delegation")
	private List<String> relDelegation;
}
