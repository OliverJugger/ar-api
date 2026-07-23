package com.bdl.epbs_fund_api.repositories.type;

import com.bdl.epbs_fund_api.model.types.RelFundSupervisoryAuthorityType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RelFundSupervisoryAuthorityTypeRepository extends JpaRepository<RelFundSupervisoryAuthorityType, Integer> {

    List<RelFundSupervisoryAuthorityType> getAllByFundFundId(Integer fundFundId);
}
