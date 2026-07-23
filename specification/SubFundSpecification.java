package com.bdl.epbs_fund_api.specification;

import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.specification.criteria.SubFundSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.sub_fund.SubFundRule;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.Getter;

@Getter
public class SubFundSpecification implements Specification<SubFund> {
	
	private static final long serialVersionUID = 1L;

	private final SubFundSearchCriteria criteria;

    private final List<SubFundRule> predicatesAnd;

    public SubFundSpecification(final SubFundSearchCriteria searchCriteria, final List<SubFundRule> predicatesAnd) {
        super();
        this.criteria = searchCriteria;
        this.predicatesAnd = predicatesAnd;
    }

    @Override
    public Predicate toPredicate(Root<SubFund> root, CriteriaQuery<?> query, CriteriaBuilder builder) {
        List<Predicate> predicatesMatch = predicatesAnd.stream()
                .filter(rule -> rule.matches(criteria))
                .map(rule -> rule.apply(root, builder, criteria))
                .toList();
        return builder.and(predicatesMatch.toArray(new Predicate[0]));
    }

}
