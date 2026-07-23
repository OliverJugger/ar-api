package com.bdl.epbs_fund_api.services.impl;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.relations.RelUCIRelatedIndividual;
import com.bdl.epbs_fund_api.repositories.RelUCIRelatedIndividualRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Deprecated(forRemoval = true, since = "25/03/2025")
public class RelUCIRelatedIndividualService {

    private final RelUCIRelatedIndividualRepository relUCIRelatedIndividualRepository;
    
    public RelUCIRelatedIndividual findById(Integer id) {
    	return relUCIRelatedIndividualRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Could not find RelUCIRelatedIndividual with id : " + id));
    }

    public void deleteById(Integer id) {
        relUCIRelatedIndividualRepository.deleteById(id);
    }

}
