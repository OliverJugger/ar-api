package com.bdl.epbs_fund_api.specification.rule.related_entity_type;

import java.util.Optional;

import org.apache.commons.lang3.BooleanUtils;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.types.RelatedEntityType;
import com.bdl.epbs_fund_api.specification.criteria.RelatedEntityTypeSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelatedEntityTypeIsAvaloqRule implements RelatedEntityTypeRule {
	private static final long serialVersionUID = 1L;

	@Override
    public boolean matches(RelatedEntityTypeSearchCriteria criteria) {
    	return Optional.ofNullable(criteria)
    			.map(RelatedEntityTypeSearchCriteria::getIsAvaloq)
    			.map(BooleanUtils::isTrue)
    			.orElse(false);
    }

    @Override
    public Predicate apply(Root<RelatedEntityType> root, CriteriaBuilder builder, RelatedEntityTypeSearchCriteria criteria) {
        return builder.equal(
        		root.get("isAvaloq"), 
        		criteria.getIsAvaloq());
    }
}
