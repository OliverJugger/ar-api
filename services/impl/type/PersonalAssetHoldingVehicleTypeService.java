package com.bdl.epbs_fund_api.services.impl.type;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.PersonalAssetHoldingVehicleType;
import com.bdl.epbs_fund_api.repositories.type.PersonalAssetHoldingVehicleTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PersonalAssetHoldingVehicleTypeService {

	private final PersonalAssetHoldingVehicleTypeRepository personalAssetHoldingVehicleTypeRepository;
	
	public List<PersonalAssetHoldingVehicleType> getAllPersonalAssetHoldingVehicleType() {
		return personalAssetHoldingVehicleTypeRepository.findAll();
	}
	
	public PersonalAssetHoldingVehicleType getPersonalAssetHoldingVehicleTypeByIntlId(String intlId) {
		return personalAssetHoldingVehicleTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
	}
}