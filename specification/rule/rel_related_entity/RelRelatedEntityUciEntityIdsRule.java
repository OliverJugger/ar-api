package com.bdl.epbs_fund_api.specification.rule.rel_related_entity;

import java.util.Optional;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.model.relations.RelRelatedEntity;
import com.bdl.epbs_fund_api.model.relations.RelUCILegalPerson;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedEntitySearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedEntityUciEntityIdsRule implements RelRelatedEntityRule {
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(RelRelatedEntitySearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(RelRelatedEntitySearchCriteria::getUciEntityIds)
				.map(CollectionUtils::isNotEmpty)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<RelRelatedEntity> root, CriteriaBuilder builder, RelRelatedEntitySearchCriteria criteria) {
		Join<UCIEntity, RelUCILegalPerson> uciEntityLegalPerson = root.join("relUciLegalPerson").join("uciEntity");
		return uciEntityLegalPerson
						.get("id")
						.in(criteria.getUciEntityIds());
	}

}
