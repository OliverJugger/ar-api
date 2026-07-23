package com.bdl.epbs_fund_api.specification;

import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.bdl.epbs_fund_api.model.relations.RelRelatedEntity;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedEntitySearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.rel_related_entity.RelRelatedEntityRule;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.Getter;

@Getter
public class RelRelatedEntitySpecification implements Specification<RelRelatedEntity>{
	
	private static final long serialVersionUID = 1L;

	private final RelRelatedEntitySearchCriteria criteria;

    private final List<RelRelatedEntityRule> predicatesAnd;

    public RelRelatedEntitySpecification(final RelRelatedEntitySearchCriteria searchCriteria, final List<RelRelatedEntityRule> predicatesAnd) {
        super();
        this.criteria = searchCriteria;
        this.predicatesAnd = predicatesAnd;
    }

    @Override
    public Predicate toPredicate(Root<RelRelatedEntity> root, CriteriaQuery<?> query, CriteriaBuilder builder) {
        List<Predicate> predicatesMatch = predicatesAnd.stream()
                .filter(rule -> rule.matches(criteria))
                .map(rule -> rule.apply(root, builder, criteria))
                .toList();
        return builder.and(predicatesMatch.toArray(new Predicate[0]));
    }

}
