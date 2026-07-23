package com.bdl.epbs_fund_api.specification;

import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.bdl.epbs_fund_api.model.types.RelatedEntityType;
import com.bdl.epbs_fund_api.specification.criteria.RelatedEntityTypeSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.related_entity_type.RelatedEntityTypeRule;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.Getter;

@Getter
public class RelatedEntityTypeSpecification implements Specification<RelatedEntityType>{
	
	private static final long serialVersionUID = 1L;

	private final RelatedEntityTypeSearchCriteria criteria;

    private final List<RelatedEntityTypeRule> predicatesAnd;

    public RelatedEntityTypeSpecification(final RelatedEntityTypeSearchCriteria searchCriteria, final List<RelatedEntityTypeRule> predicatesAnd) {
        super();
        this.criteria = searchCriteria;
        this.predicatesAnd = predicatesAnd;
    }

    @Override
    public Predicate toPredicate(Root<RelatedEntityType> root, CriteriaQuery<?> query, CriteriaBuilder builder) {
        List<Predicate> predicatesMatch = predicatesAnd.stream()
                .filter(rule -> rule.matches(criteria))
                .map(rule -> rule.apply(root, builder, criteria))
                .toList();
        return builder.and(predicatesMatch.toArray(new Predicate[0]));
    }

}
