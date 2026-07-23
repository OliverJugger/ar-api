package com.bdl.epbs_fund_api.specification.rule.rel_related_individual;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedIndividualTypeCategoryIntlIdRule implements RelRelatedIndividualRule {
  private static final long serialVersionUID = 736133610222057357L;

  @Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getRelatedIndividualTypeCategory)
				.map(Objects::nonNull)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedIndividual> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
		return builder.equal(
						root
						.join("relatedIndividualType")
						.get("relatedIndividualCategoryType")
						.get("intlId"),
					criteria.getRelatedIndividualTypeCategory().getValue());
	}

}
