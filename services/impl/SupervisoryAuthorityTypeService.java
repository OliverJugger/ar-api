package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.model.types.SupervisoryAuthorityType;
import com.bdl.epbs_fund_api.repositories.type.SupervisoryAuthorityTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class SupervisoryAuthorityTypeService {

    private final SupervisoryAuthorityTypeRepository supervisoryAuthorityTypeRepository;

    public SupervisoryAuthorityType findByIntlId(String intlId) {
        return supervisoryAuthorityTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
    }
}
