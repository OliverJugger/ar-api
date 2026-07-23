package com.bdl.epbs_fund_api.specification.rule.fund;

import com.bdl.epbs_fund_api.model.entities.Fund;
import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.specification.criteria.FundSearchCriteria;
import com.bdl.epbs_fund_api.specification.criteria.SubFundSearchCriteria;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class FundIdRule implements FundRule {

    @Override
    public boolean matches(FundSearchCriteria criteria) {
        return Optional.ofNullable(criteria)
                .map(FundSearchCriteria::getFundIds)
                .map(CollectionUtils::isNotEmpty)
                .orElse(false);
    }

    @Override
    public Predicate apply(Root<Fund> root, CriteriaBuilder builder, FundSearchCriteria criteria) {
        return builder.and(root.get("fundId")
                .in(criteria.getFundIds()));
    }

}
