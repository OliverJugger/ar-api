package com.bdl.epbs_fund_api.specification.rule.rel_related_entity;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.relations.RelRelatedEntity;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedEntitySearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedEntityActiveRule implements RelRelatedEntityRule {
  
	private static final long serialVersionUID = 1L;

    @Override
    public boolean matches(RelRelatedEntitySearchCriteria criteria) {
    	return Optional.ofNullable(criteria)
    			.map(RelRelatedEntitySearchCriteria::getActiveDate)
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
    public Predicate apply(Root<RelRelatedEntity> root, CriteriaBuilder builder, RelRelatedEntitySearchCriteria criteria) {
        return builder.or(
                builder.isNull(root.get(RelRelatedEntityRuleFields.END_DATE_FIELD_NAME)),
                builder.greaterThan(root.get(RelRelatedEntityRuleFields.END_DATE_FIELD_NAME), criteria.getActiveDate()),
                builder.and(
                		builder.isNotNull(root.get(RelRelatedEntityRuleFields.END_DATE_FIELD_NAME)),
                        builder.isNotNull(root.get(RelRelatedEntityRuleFields.TASK_UUID_FIELD_NAME)))
        );
    }
}
