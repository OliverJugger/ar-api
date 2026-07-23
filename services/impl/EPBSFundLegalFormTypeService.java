package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.model.types.FundLegalFormType;
import com.bdl.epbs_fund_api.repositories.type.EPBSFundLegalFormTypeRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class EPBSFundLegalFormTypeService {

    private final EPBSFundLegalFormTypeRepository epbsFundLegalFormTypeRepository;

    public FundLegalFormType findByIntlId(String intlId) {
        return epbsFundLegalFormTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId));
    }
}
