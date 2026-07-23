package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.model.types.RelFundRegulatedAsType;
import com.bdl.epbs_fund_api.repositories.type.RelFundRegulatedAsTypeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RelFundRegulatedAsService {

    private final RelFundRegulatedAsTypeRepository relFundRegulatedAsTypeRepository;

    public List<RelFundRegulatedAsType> getAllByFundId(Integer fundId) {
        return relFundRegulatedAsTypeRepository.getAllByFundFundId(fundId);
    }
}
