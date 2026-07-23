package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.InvestmentGeographyType;
import com.bdl.epbs_fund_api.repositories.type.InvestmentGeographyTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class InvestmentGeographyTypeService {

	private final InvestmentGeographyTypeRepository investmentGeographyTypeRepository;
	
	public List<InvestmentGeographyType> getAllInvestmentGeographyType() {
		return investmentGeographyTypeRepository.findAll();
	}

	public InvestmentGeographyType getInvestmentGeographyTypeByIntlId(String intlId) {
		return investmentGeographyTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
}
