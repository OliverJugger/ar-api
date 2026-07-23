package com.bdl.epbs_fund_api.services.impl.v2;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bdl.epbs_fund_api.model.entities.LegalPerson;
import com.bdl.epbs_fund_api.model.entities.NaturalPerson;
import com.bdl.epbs_fund_api.model.relations.v2.RelLegalPersonNaturalPersonV2;
import com.bdl.epbs_fund_api.repositories.v2.RelLegalPersonNaturalPersonRepositoryV2;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class RelLegalPersonNaturalPersonServiceV2 {

    private final RelLegalPersonNaturalPersonRepositoryV2 relLegalPersonNaturalPersonRepository;

    @Transactional
    public RelLegalPersonNaturalPersonV2 findOrCreateByLegalPersonIdAndNaturalPersonId(LegalPerson legalPerson, NaturalPerson naturalPerson) {
        return relLegalPersonNaturalPersonRepository.findByLegalPersonIdAndNaturalPersonId(legalPerson.getId(), naturalPerson.getId())
                .orElseGet(
                	() -> createRelLegalPersonNaturalPerson(legalPerson, naturalPerson));
    }
    
    private RelLegalPersonNaturalPersonV2 createRelLegalPersonNaturalPerson(LegalPerson legalPerson, NaturalPerson naturalPerson) {
		log.info(String.format("createRelLegalPersonNaturalPerson LP : %s, NP : %s", legalPerson.getId(), naturalPerson.getId()));
        RelLegalPersonNaturalPersonV2 relLegalPersonNaturalPerson = RelLegalPersonNaturalPersonV2.builder()
                .legalPerson(legalPerson)
                .naturalPerson(naturalPerson)
                .build();
        return relLegalPersonNaturalPersonRepository.save(relLegalPersonNaturalPerson);
    }

}
