package com.bdl.epbs_fund_api.services.metadata.impl;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.ElemType;
import com.bdl.epbs_fund_api.repositories.metadata.ElemTypeRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ElemTypeService {

    private final ElemTypeRepository elemTypeRepository;

    public ElemType getElemTypeByIntlId(String elemTypeIntlId) {
        return elemTypeRepository.findByIntlId(elemTypeIntlId);
    }
}
