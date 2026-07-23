package com.bdl.epbs_fund_api.specification.rule.rel_related_individual;

import java.util.Optional;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.relations.RelAccessProfileElemEpbs;
import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedIndividualDataAccessProfileRule implements RelRelatedIndividualRule {
	private static final long serialVersionUID = -5828958145910337884L;

	@Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getDataProfileIntlIds)
				.map(CollectionUtils::isNotEmpty)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedIndividual> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
		Join<RelAccessProfileElemEpbs, RelRelatedIndividual> relAccessDataSubFund = root.join("relAccessProfileElemEpbs");
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
					Constants.INTL_ID_ELEM_REL_IND));
	}
}
