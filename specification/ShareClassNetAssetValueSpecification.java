package com.bdl.epbs_fund_api.specification;

import java.time.LocalDate;
import java.util.Objects;

import org.springframework.data.jpa.domain.Specification;

import com.bdl.epbs_fund_api.model.entities.ShareClassNetAssetValue;

public class ShareClassNetAssetValueSpecification {

    private ShareClassNetAssetValueSpecification() {}

    private static Specification<ShareClassNetAssetValue> hasShareClassId(Integer shareClassId) {
        return (root, query, builder) ->
                builder.equal(root.get("shareClass").get("id"), shareClassId);
    }

    private static Specification<ShareClassNetAssetValue> hasValueDateAfterOrEqual(LocalDate dateFrom) {
        return (root, query, builder) ->
                builder.greaterThanOrEqualTo(root.get("valueDate"), dateFrom);
    }

    private static Specification<ShareClassNetAssetValue> hasValueDateBeforeOrEqual(LocalDate dateTo) {
        return (root, query, builder) ->
                builder.lessThanOrEqualTo(root.get("valueDate"), dateTo);
    }

    public static Specification<ShareClassNetAssetValue> allCriteria(Integer shareClassId, LocalDate dateFrom, LocalDate dateTo) {
        Specification<ShareClassNetAssetValue> spec = hasShareClassId(shareClassId);

        if (Objects.nonNull(dateFrom))  {
            spec = spec.and(hasValueDateAfterOrEqual(dateFrom));
        }
        if (Objects.nonNull(dateTo)) {
            spec = spec.and(hasValueDateBeforeOrEqual(dateTo));
        }

        return spec;
    }

}
