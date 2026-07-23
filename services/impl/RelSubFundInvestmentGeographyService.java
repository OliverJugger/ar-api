package com.bdl.epbs_fund_api.services.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.relations.RelSubFundInvestmentGeography;
import com.bdl.epbs_fund_api.repositories.RelSubFundInvestmentGeographyRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RelSubFundInvestmentGeographyService {
	
	@Autowired
	private RelSubFundInvestmentGeographyRepository relSubFundInvestmentGeographyRepository;
	
	public List<RelSubFundInvestmentGeography> getAllBySubFundId(Integer subFundId) {
		return relSubFundInvestmentGeographyRepository.getRelSubFundInvestmentGeographyBySubFundId(subFundId);
	}
}
