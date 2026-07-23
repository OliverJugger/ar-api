package com.bdl.epbs_fund_api.specification.rule.sub_fund;

import java.io.Serializable;

import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.specification.criteria.SubFundSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public interface SubFundRule extends Serializable {

    boolean matches(SubFundSearchCriteria criteria);
    Predicate apply(Root<SubFund> root, CriteriaBuilder builder, SubFundSearchCriteria criteria);

}
