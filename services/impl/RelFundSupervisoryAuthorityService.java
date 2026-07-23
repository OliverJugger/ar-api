package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.model.types.RelFundSupervisoryAuthorityType;
import com.bdl.epbs_fund_api.repositories.type.RelFundSupervisoryAuthorityTypeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RelFundSupervisoryAuthorityService {

    private final RelFundSupervisoryAuthorityTypeRepository relFundSupervisoryAuthorityTypeRepository;

    public List<RelFundSupervisoryAuthorityType> getAllByFundId(Integer fundId) {
        return relFundSupervisoryAuthorityTypeRepository.getAllByFundFundId(fundId);
    }
}
