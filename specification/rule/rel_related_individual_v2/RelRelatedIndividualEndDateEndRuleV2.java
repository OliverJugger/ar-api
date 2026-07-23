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
public class RelRelatedIndividualEndDateEndRuleV2 implements RelRelatedIndividualRuleV2 {
	
	private static final long serialVersionUID = 1L;
	
	@Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getEndDateEnd)
				.map(Objects::nonNull)
				.orElse(false);
	}

    @Override
    public Predicate apply(Root<RelRelatedIndividualV2> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
        return  builder.lessThanOrEqualTo(root.get(RelRelatedIndividualRuleFields.END_DATE_FIELD_NAME), criteria.getEndDateEnd());
    }
}
