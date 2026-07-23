package com.bdl.epbs_fund_api.specification.rule.rel_related_individual_v2;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.model.relations.v2.RelRelatedIndividualV2;
import com.bdl.epbs_fund_api.model.relations.v2.RelUCINaturalPersonV2;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedIndividualUciEntityIdRuleV2 implements RelRelatedIndividualRuleV2 {
	
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getUciEntityId)
				.map(Objects::nonNull)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedIndividualV2> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
		Join<UCIEntity, RelUCINaturalPersonV2> uciEntityNaturalPerson = root
				.join(RelRelatedIndividualRuleFields.REL_UCI_RELATED_INDIVIDUAL_FIELD_NAME)
				.join(RelRelatedIndividualRuleFields.REL_UCI_NATURAL_PERSON_FIELD_NAME)
				.join(RelRelatedIndividualRuleFields.UCI_ENTITY_FIELD_NAME);
		
		return builder.equal(
					uciEntityNaturalPerson
						.get(RelRelatedIndividualRuleFields.ID_FIELD_NAME),
					criteria.getUciEntityId());
	}

}
