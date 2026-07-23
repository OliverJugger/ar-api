package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.model.types.ApplicableDirectiveType;
import com.bdl.epbs_fund_api.repositories.type.ApplicableDirectiveTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class ApplicableDirectiveTypeService {

    private final ApplicableDirectiveTypeRepository applicableDirectiveTypeRepository;

    public ApplicableDirectiveType findByIntlId(String intlId) {
        return applicableDirectiveTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
    }
}
