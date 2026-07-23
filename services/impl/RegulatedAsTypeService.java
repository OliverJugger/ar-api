package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.model.types.RegulatedAsType;
import com.bdl.epbs_fund_api.repositories.type.RegulatedAsTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class RegulatedAsTypeService {

    private final RegulatedAsTypeRepository regulatedAsTypeRepository;

    public RegulatedAsType findByIntlId(String intlId) {
        return regulatedAsTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
    }
}
