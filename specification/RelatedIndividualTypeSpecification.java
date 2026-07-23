package com.bdl.epbs_fund_api.specification;

import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.bdl.epbs_fund_api.model.types.RelatedIndividualType;
import com.bdl.epbs_fund_api.specification.criteria.RelatedIndividualTypeSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.related_individual_type.RelatedIndividualTypeRule;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.Getter;

@Getter
public class RelatedIndividualTypeSpecification implements Specification<RelatedIndividualType>{
	
	private static final long serialVersionUID = 1L;

	private final transient RelatedIndividualTypeSearchCriteria criteria;

    private final List<RelatedIndividualTypeRule> predicatesAnd;

    public RelatedIndividualTypeSpecification(final RelatedIndividualTypeSearchCriteria searchCriteria, final List<RelatedIndividualTypeRule> predicatesAnd) {
        super();
        this.criteria = searchCriteria;
        this.predicatesAnd = predicatesAnd;
    }

    @Override
    public Predicate toPredicate(Root<RelatedIndividualType> root, CriteriaQuery<?> query, CriteriaBuilder builder) {
        List<Predicate> predicatesMatch = predicatesAnd.stream()
                .filter(rule -> rule.matches(criteria))
                .map(rule -> rule.apply(root, builder, criteria))
                .toList();
        return builder.and(predicatesMatch.toArray(new Predicate[0]));
    }

}
