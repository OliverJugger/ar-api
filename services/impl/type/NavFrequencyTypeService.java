package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.NavFrequencyType;
import com.bdl.epbs_fund_api.repositories.type.NavFrequencyTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class NavFrequencyTypeService {

	private final NavFrequencyTypeRepository navFrequencyTypeRepository;
	
	public List<NavFrequencyType> getAllNavFrequencyType() {
		return navFrequencyTypeRepository.findAll();
	}
	
	public NavFrequencyType getNavFrequencyTypeByIntlId(String intlId) {
		return navFrequencyTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
}
