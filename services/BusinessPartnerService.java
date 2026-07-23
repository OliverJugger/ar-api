package com.bdl.epbs_fund_api.services;

import com.bdl.epbs_fund_api.repositories.BusinessPartnerRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BusinessPartnerService {

    private final BusinessPartnerRepository businessPartnerRepository;

    @Transactional
    public void deleteByLegalPersonId(String legalPersonId) {
        businessPartnerRepository.deleteByLegalPersonId(Integer.valueOf(legalPersonId));
    }

}
