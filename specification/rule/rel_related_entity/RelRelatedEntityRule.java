package com.bdl.epbs_fund_api.specification.rule.rel_related_entity;

import java.io.Serializable;

import com.bdl.epbs_fund_api.model.relations.RelRelatedEntity;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedEntitySearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public interface RelRelatedEntityRule extends Serializable {

    boolean matches(RelRelatedEntitySearchCriteria criteria);
    Predicate apply(Root<RelRelatedEntity> root, CriteriaBuilder builder, RelRelatedEntitySearchCriteria criteria);
}
