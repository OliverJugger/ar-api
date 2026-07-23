package com.bdl.epbs_fund_api.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.relations.RelProjectInitiatorSubFundInvestorBaseType;

@Repository
public interface RelProjectInitiatorSubFundInvestorBaseTypeRepository extends JpaRepository<RelProjectInitiatorSubFundInvestorBaseType, Integer> {

	List<RelProjectInitiatorSubFundInvestorBaseType> findAllByRelProjectInitiatorSubFundSubFundId(Integer subFundId);
	
}
