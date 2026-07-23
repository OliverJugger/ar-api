package com.bdl.epbs_fund_api.specification.rule.sub_fund;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.specification.criteria.SubFundSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class SubFundFundIdRule implements SubFundRule {
	private static final long serialVersionUID = 9099103122901008600L;

	@Override
	public boolean matches(SubFundSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(SubFundSearchCriteria::getFundId)
				.map(Objects::nonNull)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<SubFund> root, CriteriaBuilder builder, SubFundSearchCriteria criteria) {
		return builder.equal(
				root.join("fund")
					.get("fundId"),
				criteria.getFundId());
	}

}
