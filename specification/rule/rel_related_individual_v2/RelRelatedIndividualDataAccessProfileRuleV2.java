package com.bdl.epbs_fund_api.specification.rule.rel_related_individual_v2;

import java.util.Optional;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.relations.RelAccessProfileElemEpbs;
import com.bdl.epbs_fund_api.model.relations.v2.RelRelatedIndividualV2;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedIndividualDataAccessProfileRuleV2 implements RelRelatedIndividualRuleV2 {
	
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getDataProfileIntlIds)
				.map(CollectionUtils::isNotEmpty)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedIndividualV2> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
		Join<RelAccessProfileElemEpbs, RelRelatedIndividualV2> relAccessDataSubFund = root.join(RelRelatedIndividualRuleFields.REL_ACCESS_PROFILE_ELEM_EPBS);
		criteria.getDataProfileIntlIds().add(Constants.INTL_ID_EPBS_PROFILE_NA);
		return builder.and(
					relAccessDataSubFund
						.join(RelRelatedIndividualRuleFields.DATA_PROFILE_FIELD_NAME)
						.get(RelRelatedIndividualRuleFields.INTL_ID_FIELD_NAME)
						.in(criteria.getDataProfileIntlIds()),
					builder.equal(
						relAccessDataSubFund
							.join(RelRelatedIndividualRuleFields.EPBS_ELEM_TYPE_FIELD_NAME)
							.get(RelRelatedIndividualRuleFields.INTL_ID_FIELD_NAME),
						Constants.INTL_ID_ELEM_REL_IND));
	}
}
