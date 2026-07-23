package com.bdl.epbs_fund_api.specification.rule.rel_related_individual;

import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.model.relations.RelUCINaturalPerson;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.springframework.stereotype.Component;

import java.util.Objects;
import java.util.Optional;

@Component
public class RelRelatedIndividualUciEntityIdRule implements RelRelatedIndividualRule {
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getUciEntityId)
				.map(Objects::nonNull)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedIndividual> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
		Join<UCIEntity, RelUCINaturalPerson> uciEntityNaturalPerson = root.join("relUCIRelatedIndividual").join("relUCINaturalPerson").join("uciEntity");
		return builder.equal(
					uciEntityNaturalPerson
						.get("id"),
					criteria.getUciEntityId());
	}

}
