package com.bdl.epbs_fund_api.services.impl;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bdl.epbs_fund_api.mappings.RelLegalPersonNaturalPersonMapper;
import com.bdl.epbs_fund_api.model.RelRelatedIndividualDTO;
import com.bdl.epbs_fund_api.model.relations.RelLegalPersonNaturalPerson;
import com.bdl.epbs_fund_api.repositories.RelLegalPersonNaturalPersonRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Deprecated(forRemoval = true, since = "25/03/2025")
public class RelLegalPersonNaturalPersonService {

    private final RelLegalPersonNaturalPersonRepository relLegalPersonNaturalPersonRepository;

    private final RelLegalPersonNaturalPersonMapper relLegalPersonNaturalPersonMapper;

    @Transactional
    public RelLegalPersonNaturalPerson createRelLegalPersonNaturalPersonFromRelRelatedIndividualDTO(RelRelatedIndividualDTO relRelatedIndividualDTO) {
        return relLegalPersonNaturalPersonRepository.findByLegalPersonIdAndNaturalPersonId(
                        Integer.valueOf(relRelatedIndividualDTO.getLegalPerson().getId()),
                        Integer.valueOf(relRelatedIndividualDTO.getNaturalPerson().getId()))
                .orElse(relLegalPersonNaturalPersonRepository.save(relLegalPersonNaturalPersonMapper.fromRelRelatedIndiviualDTOToRelLegalPersonNaturalPerson(relRelatedIndividualDTO)));
    }

}
