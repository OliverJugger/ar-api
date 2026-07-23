package com.bdl.epbs_fund_api.specification.rule.rel_related_individual;

import java.util.Objects;
import java.util.Optional;

import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.model.relations.RelUCINaturalPerson;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedIndividualUciEntityIdAndTypeIntlIdRule implements RelRelatedIndividualRule {
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getUciEntityId)
				.map(Objects::nonNull)
				.orElse(false) 
				&& 
				Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getUciEntityTypeIntlId)
				.map(StringUtils::isNotBlank)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedIndividual> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
		Join<UCIEntity, RelUCINaturalPerson> uciEntityNaturalPerson = root.join("relUCIRelatedIndividual").join("relUCINaturalPerson").join("uciEntity");
		return builder.and(
				builder.equal(
					uciEntityNaturalPerson
						.get("id"),
					criteria.getUciEntityId()),
				builder.equal(
					uciEntityNaturalPerson
						.get("type")
						.get("intlId"),
					criteria.getUciEntityTypeIntlId())
				);
	}

}
