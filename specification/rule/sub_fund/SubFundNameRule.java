package com.bdl.epbs_fund_api.specification.rule.sub_fund;

import java.util.Optional;

import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.specification.criteria.SubFundSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class SubFundNameRule implements SubFundRule {
	private static final long serialVersionUID = -3720157111082332864L;

	@Override
    public boolean matches(SubFundSearchCriteria criteria) {
    	return Optional.ofNullable(criteria)
    			.map(SubFundSearchCriteria::getName)
    			.map(StringUtils::isNotBlank)
    			.orElse(false);
    }

    @Override
    public Predicate apply(Root<SubFund> root, CriteriaBuilder builder, SubFundSearchCriteria criteria) {
        return builder.like(
        		root.get("legalName"),
        		"%" + criteria.getName() + "%");
    }
}
