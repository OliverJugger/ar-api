package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.ClientSegmentationType;
import com.bdl.epbs_fund_api.repositories.type.ClientSegmentationTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ClientSegmentationTypeService {

	private final ClientSegmentationTypeRepository clientSegmentationTypeRepository;
	
	public List<ClientSegmentationType> getAllClientSegmentationType() {
		return clientSegmentationTypeRepository.findAll();
	}
	
	public ClientSegmentationType getClientSegmentationTypeByIntlId(String intlId) {
		return clientSegmentationTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
}