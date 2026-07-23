package com.bdl.epbs_fund_api.specification.rule.related_entity_type;

import java.io.Serializable;

import com.bdl.epbs_fund_api.model.types.RelatedEntityType;
import com.bdl.epbs_fund_api.specification.criteria.RelatedEntityTypeSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public interface RelatedEntityTypeRule extends Serializable {

    boolean matches(RelatedEntityTypeSearchCriteria criteria);
    Predicate apply(Root<RelatedEntityType> root, CriteriaBuilder builder, RelatedEntityTypeSearchCriteria criteria);
}
