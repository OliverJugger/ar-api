package com.bdl.epbs_fund_api.services;

import com.bdl.epbs_fund_api.model.types.RegulatedEntityType;
import com.bdl.epbs_fund_api.repositories.type.RegulatedEntityTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class RegulatedEntityTypeService {

    private final RegulatedEntityTypeRepository regulatedEntityTypeRepository;

    public RegulatedEntityType findByIntlId(String intlId) {
        return regulatedEntityTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
    }
}
