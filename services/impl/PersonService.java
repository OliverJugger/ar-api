package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.model.PersonDTO;
import com.bdl.epbs_fund_api.repositories.IPersonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class PersonService {

    private final IPersonRepository personRepository;

    public PersonDTO getPersonByUciEntityId(Integer uciEntityId) {

        return new PersonDTO().id(personRepository.getPersonIdByUCIEntityId(uciEntityId));
    }
}