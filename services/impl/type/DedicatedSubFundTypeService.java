package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.DedicatedSubFundType;
import com.bdl.epbs_fund_api.repositories.type.DedicatedSubFundTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DedicatedSubFundTypeService {

	private final DedicatedSubFundTypeRepository dedicatedSubFundTypeRepository;
	
	public List<DedicatedSubFundType> getAllDedicatedSubFundType() {
		return dedicatedSubFundTypeRepository.findAll();
	}
	
	public DedicatedSubFundType getDedicatedSubFundTypeByIntlId(String intlId) {
		return dedicatedSubFundTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
}