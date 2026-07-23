package com.bdl.epbs_fund_api.specification.rule.fund;

import com.bdl.epbs_fund_api.model.entities.Fund;
import com.bdl.epbs_fund_api.specification.criteria.FundSearchCriteria;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

import java.io.Serializable;

public interface FundRule extends Serializable {

    boolean matches(FundSearchCriteria criteria);
    Predicate apply(Root<Fund> root, CriteriaBuilder builder, FundSearchCriteria criteria);

}
