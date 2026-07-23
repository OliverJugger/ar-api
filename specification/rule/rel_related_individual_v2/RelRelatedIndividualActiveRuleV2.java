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
public class RelRelatedIndividualActiveRuleV2 implements RelRelatedIndividualRuleV2 {
	  
	private static final long serialVersionUID = 1L;

	@Override
    public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
    	return Optional.ofNullable(criteria)
    			.map(RelRelatedIndividualSearchCriteria::getActiveDate)
    			.map(Objects::nonNull)
    			.orElse(false);
    }
	
    /**
     * Active if :
     *  - No end date (validTo IS NULL)
     *  - End date in future (validTo greaterThan today)
     *  - End date present and task is present too (validTo NOT NULL && taskUid NOT NULL)
     */
    @Override
    public Predicate apply(Root<RelRelatedIndividualV2> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
        return builder.or(
                builder.isNull(root.get(RelRelatedIndividualRuleFields.END_DATE_FIELD_NAME)),
                builder.greaterThan(root.get(RelRelatedIndividualRuleFields.END_DATE_FIELD_NAME), criteria.getActiveDate()),
                builder.and(
                		builder.isNotNull(root.get(RelRelatedIndividualRuleFields.END_DATE_FIELD_NAME)),
                        builder.isNotNull(root.get(RelRelatedIndividualRuleFields.TASK_UUID_FIELD_NAME)))
        );
    }
}
