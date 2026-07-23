package com.bdl.epbs_fund_api.specification.rule.rel_related_individual;

import com.bdl.epbs_fund_api.model.entities.NaturalPerson;
import com.bdl.epbs_fund_api.model.relations.RelLegalPersonNaturalPerson;
import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.model.relations.RelUCINaturalPerson;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.springframework.stereotype.Component;

import java.util.Objects;
import java.util.Optional;

@Component
public class RelRelatedIndividualNaturalPersonIdRule implements RelRelatedIndividualRule {
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedIndividualSearchCriteria::getNaturalPersonId)
				.map(Objects::nonNull)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedIndividual> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {

		Join<NaturalPerson, RelUCINaturalPerson> uciEntityNaturalPerson = root.join("relUCIRelatedIndividual", JoinType.LEFT).join("relUCINaturalPerson", JoinType.LEFT).join("naturalPerson", JoinType.LEFT);

        Join<NaturalPerson, RelLegalPersonNaturalPerson> legalPersonNaturalPerson = root.join("relLegalPersonRelatedIndividual", JoinType.LEFT).join("relLegalPersonNaturalPerson", JoinType.LEFT).join("naturalPerson", JoinType.LEFT);

		return builder.or(
				builder.equal(
						uciEntityNaturalPerson
								.get("id"),
						criteria.getNaturalPersonId()),
				builder.equal(
						legalPersonNaturalPerson
								.get("id"),
						criteria.getNaturalPersonId())
		);
	}

}
