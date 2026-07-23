package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.model.types.ApplicableLawType;
import com.bdl.epbs_fund_api.repositories.type.ApplicableLawTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class ApplicableLawTypeService {

    private final ApplicableLawTypeRepository applicableLawTypeRepository;

    public ApplicableLawType findByIntlId(String intlId) {
        return applicableLawTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
    }
}
