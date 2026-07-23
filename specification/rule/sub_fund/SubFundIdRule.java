package com.bdl.epbs_fund_api.specification.rule.sub_fund;

import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.specification.criteria.SubFundSearchCriteria;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.apache.commons.collections4.CollectionUtils;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class SubFundIdRule implements SubFundRule {
	@Override
	public boolean matches(SubFundSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(SubFundSearchCriteria::getSubFundIds)
				.map(CollectionUtils::isNotEmpty)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<SubFund> root, CriteriaBuilder builder, SubFundSearchCriteria criteria) {
		return builder.and(root.get("id")
				.in(criteria.getSubFundIds()));
	}

}
