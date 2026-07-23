package com.bdl.epbs_fund_api.specification.v2;

import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.bdl.epbs_fund_api.model.relations.v2.RelRelatedIndividualV2;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.rel_related_individual_v2.RelRelatedIndividualRuleV2;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public class RelRelatedIndividualSpecificationV2 implements Specification<RelRelatedIndividualV2>{
	
	private static final long serialVersionUID = 1L;

	private final RelRelatedIndividualSearchCriteria criteria;

    private final List<RelRelatedIndividualRuleV2> predicatesAnd;

    public RelRelatedIndividualSpecificationV2(final RelRelatedIndividualSearchCriteria searchCriteria, final List<RelRelatedIndividualRuleV2> predicatesAnd) {
        super();
        this.criteria = searchCriteria;
        this.predicatesAnd = predicatesAnd;
    }

    @Override
    public Predicate toPredicate(Root<RelRelatedIndividualV2> root, CriteriaQuery<?> query, CriteriaBuilder builder) {
        List<Predicate> predicatesMatch = predicatesAnd.stream()
                .filter(rule -> rule.matches(criteria))
                .map(rule -> rule.apply(root, builder, criteria))
                .toList();
        return builder.and(predicatesMatch.toArray(new Predicate[0]));
    }

}
