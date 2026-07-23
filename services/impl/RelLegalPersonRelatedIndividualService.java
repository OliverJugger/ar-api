package com.bdl.epbs_fund_api.services.impl;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.relations.RelLegalPersonRelatedIndividual;
import com.bdl.epbs_fund_api.repositories.RelLegalPersonRelatedIndividualRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Deprecated(forRemoval = true, since = "25/03/2025")
public class RelLegalPersonRelatedIndividualService {

    private final RelLegalPersonRelatedIndividualRepository relLegalPersonRelatedIndividualRepository;

    public RelLegalPersonRelatedIndividual findById(Integer id) {
    	return relLegalPersonRelatedIndividualRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Could not find RelLegalPersonRelatedIndividual with id : " + id));
    }
    
    public void deleteById(Integer id) {
        relLegalPersonRelatedIndividualRepository.deleteById(id);
    }

}
