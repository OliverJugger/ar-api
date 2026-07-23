package com.bdl.epbs_fund_api.specification.rule.rel_related_individual_v2;

import java.io.Serializable;

import com.bdl.epbs_fund_api.model.relations.v2.RelRelatedIndividualV2;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public interface RelRelatedIndividualRuleV2 extends Serializable {

    boolean matches(RelRelatedIndividualSearchCriteria criteria);
    Predicate apply(Root<RelRelatedIndividualV2> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria);
}
