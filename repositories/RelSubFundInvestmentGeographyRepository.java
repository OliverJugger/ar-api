package com.bdl.epbs_fund_api.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.bdl.epbs_fund_api.model.relations.RelSubFundInvestmentGeography;

public interface RelSubFundInvestmentGeographyRepository extends JpaRepository<RelSubFundInvestmentGeography, Integer> {
	
	List<RelSubFundInvestmentGeography> getRelSubFundInvestmentGeographyBySubFundId(Integer subFundId);
	
}
