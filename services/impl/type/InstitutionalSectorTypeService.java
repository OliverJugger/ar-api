package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.InstitutionalSectorType;
import com.bdl.epbs_fund_api.repositories.type.InstitutionalSectorTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class InstitutionalSectorTypeService {

	private final InstitutionalSectorTypeRepository institutionalSectorTypeRepository;
	
	public List<InstitutionalSectorType> getAllInstitutionalSectorType() {
		return institutionalSectorTypeRepository.findAll();
	}

	public InstitutionalSectorType getInstitutionalSectorTypeByIntlId(String intlId) {
		return institutionalSectorTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
}
