package com.bdl.epbs_fund_api.specification;

import com.bdl.epbs_fund_api.model.entities.Fund;
import com.bdl.epbs_fund_api.specification.criteria.FundSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.fund.FundRule;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.data.jpa.domain.Specification;

import java.util.List;

@Data
public class FundSpecification implements Specification<Fund> {

    private final FundSearchCriteria criteria;

    private final List<FundRule> predicatesAnd;

    public FundSpecification(final FundSearchCriteria searchCriteria, final List<FundRule> predicatesAnd) {
        super();
        this.criteria = searchCriteria;
        this.predicatesAnd = predicatesAnd;
    }

    @Override
    public Predicate toPredicate(Root<Fund> root, CriteriaQuery<?> query, CriteriaBuilder criteriaBuilder) {
        List<Predicate> predicatesMatch = predicatesAnd.stream()
                .filter(rule -> rule.matches(criteria))
                .map(rule -> rule.apply(root, criteriaBuilder, criteria))
                .toList();
        return criteriaBuilder.and(predicatesMatch.toArray(new Predicate[0]));
    }
}
