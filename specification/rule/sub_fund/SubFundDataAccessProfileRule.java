package com.bdl.epbs_fund_api.specification.rule.sub_fund;

import java.util.Optional;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.model.relations.RelAccessProfileElemEpbs;
import com.bdl.epbs_fund_api.specification.criteria.SubFundSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class SubFundDataAccessProfileRule implements SubFundRule {
	private static final long serialVersionUID = -2330505731688607516L;

	@Override
	public boolean matches(SubFundSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(SubFundSearchCriteria::getDataProfileIntlIds)
				.map(CollectionUtils::isNotEmpty)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<SubFund> root, CriteriaBuilder builder, SubFundSearchCriteria criteria) {
		Join<RelAccessProfileElemEpbs, SubFund> relAccessDataSubFund = root.join("relAccessProfileElemEpbs");
		criteria.getDataProfileIntlIds().add(Constants.INTL_ID_EPBS_PROFILE_NA);
		return builder.and(
					relAccessDataSubFund
						.join("dataProfile")
						.get("intlId")
						.in(criteria.getDataProfileIntlIds()),
				builder.equal(
					relAccessDataSubFund
						.join("epbsElemType")
						.get("intlId"),
					Constants.INTL_ID_ELEM_SUBFUND));
	}
}
