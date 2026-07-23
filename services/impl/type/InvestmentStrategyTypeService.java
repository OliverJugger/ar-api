package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.InvestmentStrategyType;
import com.bdl.epbs_fund_api.repositories.type.InvestmentStrategyTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class InvestmentStrategyTypeService {

	private final InvestmentStrategyTypeRepository investmentStrategyTypeRepository;
	
	public List<InvestmentStrategyType> getAllInvestmentStrategyType() {
		return investmentStrategyTypeRepository.findAll();
	}
	
	public InvestmentStrategyType getInvestmentStrategyTypeByIntlId(String intlId) {
		return investmentStrategyTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
}
