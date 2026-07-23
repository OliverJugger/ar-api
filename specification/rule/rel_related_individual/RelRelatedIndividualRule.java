package com.bdl.epbs_fund_api.specification.rule.rel_related_individual;

import java.io.Serializable;

import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public interface RelRelatedIndividualRule extends Serializable {

    boolean matches(RelRelatedIndividualSearchCriteria criteria);
    Predicate apply(Root<RelRelatedIndividual> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria);
}
