package com.bdl.epbs_fund_api.specification.rule.related_individual_type;

import java.util.Optional;

import org.apache.commons.lang3.BooleanUtils;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.types.RelatedIndividualType;
import com.bdl.epbs_fund_api.specification.criteria.RelatedIndividualTypeSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelatedIndividualTypeIsFundRule implements RelatedIndividualTypeRule {
	private static final long serialVersionUID = 1L;

	@Override
    public boolean matches(RelatedIndividualTypeSearchCriteria criteria) {
    	return Optional.ofNullable(criteria)
    			.map(RelatedIndividualTypeSearchCriteria::getIsFund)
    			.map(BooleanUtils::isTrue)
    			.orElse(false);
    }

    @Override
    public Predicate apply(Root<RelatedIndividualType> root, CriteriaBuilder builder, RelatedIndividualTypeSearchCriteria criteria) {
        return builder.equal(
        		root.get("isFund"), 
        		criteria.getIsFund());
    }
}
