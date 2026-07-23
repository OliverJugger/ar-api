package com.bdl.epbs_fund_api.services.impl.v2;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bdl.epbs_fund_api.model.entities.NaturalPerson;
import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.model.relations.v2.RelUCINaturalPersonV2;
import com.bdl.epbs_fund_api.repositories.v2.RelUCINaturalPersonRepositoryV2;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class RelUCINaturalPersonServiceV2 {

    private final RelUCINaturalPersonRepositoryV2 relUCINaturalPersonRepository;

    @Transactional
    public RelUCINaturalPersonV2 findOrCreateByUciEntityIdAndNaturalPersonId(UCIEntity uciEntity, NaturalPerson naturalPerson) {
        return relUCINaturalPersonRepository
                .findByUciEntityIdAndNaturalPersonId(uciEntity.getId(), naturalPerson.getId())
                .orElseGet(
                		() -> createRelUCINaturalPerson(uciEntity, naturalPerson));
    }
    
    private RelUCINaturalPersonV2 createRelUCINaturalPerson(UCIEntity uciEntity, NaturalPerson naturalPerson) {
		log.info(String.format("createRelUCINaturalPerson NP : %s, UCI : %s", naturalPerson.getId(), uciEntity.getId()));
		RelUCINaturalPersonV2 relUciNp = RelUCINaturalPersonV2.builder()
                .naturalPerson(naturalPerson)
                .uciEntity(uciEntity)
                .build();
        return relUCINaturalPersonRepository.save(relUciNp);
    }
}
