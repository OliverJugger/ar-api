package com.bdl.epbs_fund_api.specification.rule.rel_related_entity;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.entities.LegalPerson;
import com.bdl.epbs_fund_api.model.relations.RelRelatedEntity;
import com.bdl.epbs_fund_api.model.relations.RelUCILegalPerson;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedEntitySearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedEntityLegalPersonIdRule implements RelRelatedEntityRule {
	
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedEntitySearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedEntitySearchCriteria::getLegalPersonId)
				.map(Objects::nonNull)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedEntity> root, CriteriaBuilder builder, RelRelatedEntitySearchCriteria criteria) {
		Join<LegalPerson, RelUCILegalPerson> uciEntityLegalPerson = root
				.join(RelRelatedEntityRuleFields.REL_UCI_LEGAL_PERSON_FIELD_NAME)
				.join(RelRelatedEntityRuleFields.LEGAL_PERSON_FIELD_NAME);
		return builder.equal(
					uciEntityLegalPerson
						.get(RelRelatedEntityRuleFields.ID_FIELD_NAME),
					criteria.getLegalPersonId());
	}

}
