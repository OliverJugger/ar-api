package com.bdl.epbs_fund_api.specification.rule.fund;

import java.util.Optional;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.entities.Fund;
import com.bdl.epbs_fund_api.model.relations.RelAccessProfileElemEpbs;
import com.bdl.epbs_fund_api.specification.criteria.FundSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class FundDataAccessProfileRule implements FundRule {
	private static final long serialVersionUID = -2330505731688607516L;

	@Override
	public boolean matches(FundSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(FundSearchCriteria::getDataProfileIntlIds)
				.map(CollectionUtils::isNotEmpty)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<Fund> root, CriteriaBuilder builder, FundSearchCriteria criteria) {
		Join<RelAccessProfileElemEpbs, Fund> relAccessDataFund = root.join("relAccessProfileElemEpbs");
		criteria.getDataProfileIntlIds().add(Constants.INTL_ID_EPBS_PROFILE_NA);
		return builder.and(
					relAccessDataFund
						.join("dataProfile")
						.get("intlId")
						.in(criteria.getDataProfileIntlIds()),
				builder.equal(
					relAccessDataFund
						.join("epbsElemType")
						.get("intlId"),
					Constants.INTL_ID_ELEM_FUND));
	}
}
