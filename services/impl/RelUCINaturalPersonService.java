package com.bdl.epbs_fund_api.services.impl;

import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bdl.epbs_fund_api.mappings.RelUCINaturalPersonMapper;
import com.bdl.epbs_fund_api.model.FundDTO;
import com.bdl.epbs_fund_api.model.RelRelatedIndividualDTO;
import com.bdl.epbs_fund_api.model.SubFundDTO;
import com.bdl.epbs_fund_api.model.relations.RelUCINaturalPerson;
import com.bdl.epbs_fund_api.repositories.RelUCINaturalPersonRepository;
import com.bdl.utils.exceptions.BadRequestException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Deprecated(forRemoval = true, since = "25/03/2025")
public class RelUCINaturalPersonService {

    private final RelUCINaturalPersonRepository relUCINaturalPersonRepository;

    private final RelUCINaturalPersonMapper relUCINaturalPersonMapper;

    @Deprecated(forRemoval = true, since = "25/03/2025")
    @Transactional
    public RelUCINaturalPerson createRelUCINaturalPersonFromRelRelatedIndividualDTO(RelRelatedIndividualDTO relRelatedIndividualDTO) {
        return Optional.ofNullable(relRelatedIndividualDTO.getFund())
                .map(FundDTO::getFundId)
                .map(fundId -> relUCINaturalPersonRepository.findByUciEntityIdAndNaturalPersonId(
                            Integer.valueOf(fundId),
                            Integer.valueOf(relRelatedIndividualDTO.getNaturalPerson().getId()))
                        .orElseGet(() -> relUCINaturalPersonRepository.save(relUCINaturalPersonMapper.fromRelRelatedIndiviualDTOToRelUCINaturalPerson(relRelatedIndividualDTO))))
                .orElseGet(() -> Optional.ofNullable(relRelatedIndividualDTO.getSubFund())
                        .map(SubFundDTO::getId)
                        .map(subFundId -> relUCINaturalPersonRepository.findByUciEntityIdAndNaturalPersonId(
                                    Integer.valueOf(subFundId),
                                    Integer.valueOf(relRelatedIndividualDTO.getNaturalPerson().getId()))
                                .orElseGet(() -> relUCINaturalPersonRepository.save(relUCINaturalPersonMapper.fromRelRelatedIndiviualDTOToRelUCINaturalPerson(relRelatedIndividualDTO))))
                        .orElseThrow(() -> new BadRequestException("Neither a fund id or a subfund id has been found in the request body")));
    }
}
