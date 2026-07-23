package com.bdl.epbs_fund_api.services.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.UCIEntityType;
import com.bdl.epbs_fund_api.repositories.type.UCIEntityTypeRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UCIEntityTypeService {
	
	@Autowired
	private UCIEntityTypeRepository uCIEntityTypeRepository;

	public List<UCIEntityType> getAllUCIEntityType() {
		return uCIEntityTypeRepository.findAll();
	}

	public UCIEntityType getUCIEntityTypeByIntlId(String intlId) {
		return uCIEntityTypeRepository.findByIntlId(intlId);
	}

}
