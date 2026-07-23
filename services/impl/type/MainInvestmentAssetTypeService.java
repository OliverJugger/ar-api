package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.MainInvestmentAssetType;
import com.bdl.epbs_fund_api.repositories.type.MainInvestmentAssetTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MainInvestmentAssetTypeService {

	private final MainInvestmentAssetTypeRepository mainInvestmentAssetTypeRepository;
	
	public List<MainInvestmentAssetType> getAllMainInvestmentAssetType() {
		return mainInvestmentAssetTypeRepository.findAll();
	}
	
	public MainInvestmentAssetType getMainInvestmentAssetTypeByIntlId(String intlId) {
		return mainInvestmentAssetTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
}
