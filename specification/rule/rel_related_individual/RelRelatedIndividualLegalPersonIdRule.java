package com.bdl.epbs_fund_api.specification.rule.rel_related_individual;

import com.bdl.epbs_fund_api.model.entities.LegalPerson;
import com.bdl.epbs_fund_api.model.relations.RelLegalPersonNaturalPerson;
import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.springframework.stereotype.Component;

import java.util.Objects;
import java.util.Optional;

@Component
public class RelRelatedIndividualLegalPersonIdRule implements RelRelatedIndividualRule {
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getLegalPersonId)
				.map(Objects::nonNull)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedIndividual> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
		Join<LegalPerson, RelLegalPersonNaturalPerson> legalPersonNaturalPerson = root.join("relLegalPersonRelatedIndividual").join("relLegalPersonNaturalPerson").join("legalPerson");
		return builder.equal(
				legalPersonNaturalPerson
						.get("id"),
					criteria.getLegalPersonId());
	}

}
