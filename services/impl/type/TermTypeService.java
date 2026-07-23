package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.TermType;
import com.bdl.epbs_fund_api.repositories.type.TermTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TermTypeService {

	private final TermTypeRepository termTypeRepository;
	
	public List<TermType> getAllTermType() {
		return termTypeRepository.findAll();
	}
	
	public TermType getTermTypeByIntlId(String intlId) {
		return termTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
	
}
