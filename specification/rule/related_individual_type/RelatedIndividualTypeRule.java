package com.bdl.epbs_fund_api.specification.rule.related_individual_type;

import java.io.Serializable;

import com.bdl.epbs_fund_api.model.types.RelatedIndividualType;
import com.bdl.epbs_fund_api.specification.criteria.RelatedIndividualTypeSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public interface RelatedIndividualTypeRule extends Serializable {

    boolean matches(RelatedIndividualTypeSearchCriteria criteria);
    Predicate apply(Root<RelatedIndividualType> root, CriteriaBuilder builder, RelatedIndividualTypeSearchCriteria criteria);
}
