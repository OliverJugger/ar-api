package com.bdl.epbs_fund_api.specification;

import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.rel_related_individual.RelRelatedIndividualRule;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public class RelRelatedIndividualSpecification implements Specification<RelRelatedIndividual>{
	
	private static final long serialVersionUID = 1L;

	private final RelRelatedIndividualSearchCriteria criteria;

    private final List<RelRelatedIndividualRule> predicatesAnd;

    public RelRelatedIndividualSpecification(final RelRelatedIndividualSearchCriteria searchCriteria, final List<RelRelatedIndividualRule> predicatesAnd) {
        super();
        this.criteria = searchCriteria;
        this.predicatesAnd = predicatesAnd;
    }

    @Override
    public Predicate toPredicate(Root<RelRelatedIndividual> root, CriteriaQuery<?> query, CriteriaBuilder builder) {
        List<Predicate> predicatesMatch = predicatesAnd.stream()
                .filter(rule -> rule.matches(criteria))
                .map(rule -> rule.apply(root, builder, criteria))
                .toList();
        return builder.and(predicatesMatch.toArray(new Predicate[0]));
    }

}
