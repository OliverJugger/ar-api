package com.bdl.epbs_fund_api.specification.rule.rel_related_individual_v2;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.relations.v2.RelRelatedIndividualV2;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedIndividualTypeIntlIdRuleV2 implements RelRelatedIndividualRuleV2 {
  
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getRelatedIndividualType)
				.map(Objects::nonNull)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedIndividualV2> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
		return builder.equal(
						root
						.join(RelRelatedIndividualRuleFields.RELATED_INDIVIDUAL_TYPE_FIELD_NAME)
						.get(RelRelatedIndividualRuleFields.INTL_ID_FIELD_NAME),
					criteria.getRelatedIndividualType().getValue());
	}

}
