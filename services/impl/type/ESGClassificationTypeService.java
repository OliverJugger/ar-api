package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.ESGClassificationType;
import com.bdl.epbs_fund_api.repositories.type.ESGClassificationTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ESGClassificationTypeService {

	private final ESGClassificationTypeRepository eSGClassificationTypeRepository;
	
	public List<ESGClassificationType> getAllESGClassificationType() {
		return eSGClassificationTypeRepository.findAll();
	}
	
	public ESGClassificationType getESGClassificationTypeByIntlId(String intlId) {
		return eSGClassificationTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
}
