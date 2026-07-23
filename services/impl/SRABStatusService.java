package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.model.types.SRABStatusType;
import com.bdl.epbs_fund_api.repositories.type.SRABStatusRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class SRABStatusService {

    private final SRABStatusRepository srabStatusRepository;

    public SRABStatusType findByIntlId(String intlId) {
        return srabStatusRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
    }
}
