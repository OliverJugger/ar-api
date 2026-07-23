package com.bdl.epbs_fund_api.specification.rule.rel_related_entity;

import java.util.Optional;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.relations.RelAccessProfileElemEpbs;
import com.bdl.epbs_fund_api.model.relations.RelRelatedEntity;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedEntitySearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedEntityDataAccessProfileRule implements RelRelatedEntityRule {
	
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedEntitySearchCriteria criteria) {
		return  Optional.ofNullable(criteria)
				.map(RelRelatedEntitySearchCriteria::getDataProfileIntlIds)
				.map(CollectionUtils::isNotEmpty)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedEntity> root, CriteriaBuilder builder, RelRelatedEntitySearchCriteria criteria) {
		Join<RelAccessProfileElemEpbs, RelRelatedEntity> relAccessDataSubFund = root
				.join(RelRelatedEntityRuleFields.REL_ACCESS_PROFILE_ELEM_EPBS);
		criteria.getDataProfileIntlIds().add(Constants.INTL_ID_EPBS_PROFILE_NA);
		return builder.and(
					relAccessDataSubFund
						.join(RelRelatedEntityRuleFields.DATA_PROFILE_FIELD_NAME)
						.get(RelRelatedEntityRuleFields.INTL_ID_FIELD_NAME)
						.in(criteria.getDataProfileIntlIds()),
				builder.equal(
					relAccessDataSubFund
						.join(RelRelatedEntityRuleFields.EPBS_ELEM_TYPE_FIELD_NAME)
						.get(RelRelatedEntityRuleFields.INTL_ID_FIELD_NAME),
					Constants.INTL_ID_ELEM_REL_ENT));
	}
}
