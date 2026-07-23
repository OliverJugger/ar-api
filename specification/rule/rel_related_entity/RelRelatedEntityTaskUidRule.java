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
public class RelRelatedEntityTaskUidRule implements RelRelatedEntityRule {
	
	private static final long serialVersionUID = 1L;

	@Override
    public boolean matches(RelRelatedEntitySearchCriteria criteria) {
    	return Optional.ofNullable(criteria)
    			.map(RelRelatedEntitySearchCriteria::getTaskUid)
    			.map(Objects::nonNull)
    			.orElse(false);
    }

    @Override
    public Predicate apply(Root<RelRelatedEntity> root, CriteriaBuilder builder, RelRelatedEntitySearchCriteria criteria) {
        return builder.equal(
        		root.get(RelRelatedEntityRuleFields.TASK_UUID_FIELD_NAME), 
        		criteria.getTaskUid().toString());
    }
}
