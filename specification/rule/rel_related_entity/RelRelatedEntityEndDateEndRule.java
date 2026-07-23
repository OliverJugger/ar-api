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
public class RelRelatedEntityEndDateEndRule implements RelRelatedEntityRule {
	
	private static final long serialVersionUID = 1L;
	
	@Override
	public boolean matches(RelRelatedEntitySearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedEntitySearchCriteria::getEndDateEnd)
				.map(Objects::nonNull)
				.orElse(false);
	}

    @Override
    public Predicate apply(Root<RelRelatedEntity> root, CriteriaBuilder builder, RelRelatedEntitySearchCriteria criteria) {
        return  builder.lessThanOrEqualTo(root.get(RelRelatedEntityRuleFields.END_DATE_FIELD_NAME), criteria.getEndDateEnd());
    }
}
