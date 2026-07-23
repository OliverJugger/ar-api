package com.bdl.epbs_fund_api.services.impl;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.entities.LegalPerson;
import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.model.relations.RelUCILegalPerson;
import com.bdl.epbs_fund_api.repositories.RelUCILegalPersonRepository;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class RelUCILegalPersonService {

	private final RelUCILegalPersonRepository relUCILegalPersonRepository;
	
	public RelUCILegalPersonService(RelUCILegalPersonRepository relUCILegalPersonRepository) {
		this.relUCILegalPersonRepository = relUCILegalPersonRepository;
	}

	public RelUCILegalPerson findOrCreateByLegalPersonIdAndUciEntityId(LegalPerson legalPerson, UCIEntity uciEntity) {
		return relUCILegalPersonRepository.findByLegalPersonIdAndUciEntityId(legalPerson.getId(), uciEntity.getId())
				.orElseGet( 
					() -> createRelUCILegalPerson(legalPerson, uciEntity));
	}
	
	private RelUCILegalPerson createRelUCILegalPerson(LegalPerson legalPerson, UCIEntity uciEntity) {
		log.info(String.format("createRelUCILegalPerson LP : %s, UCI : %s", legalPerson.getId(), uciEntity.getId()));
		RelUCILegalPerson relUCILegalPerson = RelUCILegalPerson.builder()
				.legalPerson(legalPerson)
				.uciEntity(uciEntity)
				.build();
		return relUCILegalPersonRepository.save(relUCILegalPerson);
	}

}