package com.bdl.epbs_fund_api.specification;

import java.time.LocalDate;
import java.util.Objects;

import org.springframework.data.jpa.domain.Specification;

import com.bdl.epbs_fund_api.model.entities.SubFundNetAssetValue;

public class SubFundNetAssetValueSpecification {

    private SubFundNetAssetValueSpecification() {}

    public static Specification<SubFundNetAssetValue> allCriteria(Integer subFundId, LocalDate dateFrom, LocalDate dateTo) {
        Specification<SubFundNetAssetValue> spec = hasSubFundId(subFundId);

        if (Objects.nonNull(dateFrom))  {
            spec = spec.and(hasValueDateAfterOrEqual(dateFrom));
        }
        if (Objects.nonNull(dateTo)) {
            spec = spec.and(hasValueDateBeforeOrEqual(dateTo));
        }

        return spec;
    }

    private static Specification<SubFundNetAssetValue> hasSubFundId(Integer subFundId) {
        return (root, query, builder) ->
                builder.equal(root.get("subFund").get("id"), subFundId);
    }

    private static Specification<SubFundNetAssetValue> hasValueDateAfterOrEqual(LocalDate dateFrom) {
        return (root, query, builder) ->
                builder.greaterThanOrEqualTo(root.get("valueDate"), dateFrom);
    }

    private static Specification<SubFundNetAssetValue> hasValueDateBeforeOrEqual(LocalDate dateTo) {
        return (root, query, builder) ->
                builder.lessThanOrEqualTo(root.get("valueDate"), dateTo);
    }
}
