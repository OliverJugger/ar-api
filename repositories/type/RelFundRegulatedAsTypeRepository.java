package com.bdl.epbs_fund_api.repositories.type;

import com.bdl.epbs_fund_api.model.types.RelFundRegulatedAsType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RelFundRegulatedAsTypeRepository extends JpaRepository<RelFundRegulatedAsType, Integer> {

    List<RelFundRegulatedAsType> getAllByFundFundId(Integer fundId);
}
