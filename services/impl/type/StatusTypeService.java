package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.StatusType;
import com.bdl.epbs_fund_api.repositories.type.StatusTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class StatusTypeService {

	private final StatusTypeRepository statusTypeRepository;
	
	public List<StatusType> getAllClientSegmentationType() {
		return statusTypeRepository.findAll();
	}
	
	public StatusType getStatusTypeByIntlId(String intlId) {
		return statusTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
}