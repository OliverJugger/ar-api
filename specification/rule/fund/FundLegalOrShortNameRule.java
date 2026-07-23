package com.bdl.epbs_fund_api.specification.rule.fund;

import com.bdl.epbs_fund_api.model.entities.Fund;
import com.bdl.epbs_fund_api.specification.criteria.FundSearchCriteria;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Component;
import java.util.Optional;

@Component
public class FundLegalOrShortNameRule implements FundRule {

    @Override
    public boolean matches(FundSearchCriteria criteria) {
        return Optional.ofNullable(criteria)
                .map(FundSearchCriteria::getName)
                .map(StringUtils::isNotBlank)
                .orElse(false);
    }

    @Override
    public Predicate apply(Root<Fund> root, CriteriaBuilder builder, FundSearchCriteria criteria) {
        return builder.or(
                builder.like(root.get("legalName"), "%" + criteria.getName() + "%"),
                builder.like(root.get("internalShortName"), "%" + criteria.getName() + "%")
        );
    }
}
