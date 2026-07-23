package com.bdl.epbs_fund_api.specification.rule.rel_related_individual_v2;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.entities.NaturalPerson;
import com.bdl.epbs_fund_api.model.relations.v2.RelLegalPersonNaturalPersonV2;
import com.bdl.epbs_fund_api.model.relations.v2.RelRelatedIndividualV2;
import com.bdl.epbs_fund_api.model.relations.v2.RelUCINaturalPersonV2;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedIndividualNaturalPersonIdRuleV2 implements RelRelatedIndividualRuleV2 {
	
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getNaturalPersonId)
				.map(Objects::nonNull)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedIndividualV2> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {

		Join<NaturalPerson, RelUCINaturalPersonV2> uciEntityNaturalPerson = root
				.join(RelRelatedIndividualRuleFields.REL_UCI_RELATED_INDIVIDUAL_FIELD_NAME, JoinType.LEFT)
				.join(RelRelatedIndividualRuleFields.REL_UCI_NATURAL_PERSON_FIELD_NAME, JoinType.LEFT)
				.join(RelRelatedIndividualRuleFields.NATURAL_PERSON_FIELD_NAME, JoinType.LEFT);

        Join<NaturalPerson, RelLegalPersonNaturalPersonV2> legalPersonNaturalPerson = root
        		.join(RelRelatedIndividualRuleFields.REL_LEGAL_PERSON_RELATED_INDIVIDUAL_FIELD_NAME, JoinType.LEFT)
        		.join(RelRelatedIndividualRuleFields.REL_LEGAL_PERSON_NATURAL_PERSON_FIELD_NAME, JoinType.LEFT)
        		.join(RelRelatedIndividualRuleFields.NATURAL_PERSON_FIELD_NAME, JoinType.LEFT);

		return builder.or(
				builder.equal(
						uciEntityNaturalPerson
								.get(RelRelatedIndividualRuleFields.ID_FIELD_NAME),
						criteria.getNaturalPersonId()),
				builder.equal(
						legalPersonNaturalPerson
								.get(RelRelatedIndividualRuleFields.ID_FIELD_NAME),
						criteria.getNaturalPersonId())
		);
	}

}
