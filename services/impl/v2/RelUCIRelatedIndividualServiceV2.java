package com.bdl.epbs_fund_api.services.impl.v2;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.relations.v2.RelUCIRelatedIndividualV2;
import com.bdl.epbs_fund_api.repositories.v2.RelUCIRelatedIndividualRepositoryV2;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RelUCIRelatedIndividualServiceV2 {

    private final RelUCIRelatedIndividualRepositoryV2 relUCIRelatedIndividualRepository;
    
    public RelUCIRelatedIndividualV2 findById(Integer id) {
    	return relUCIRelatedIndividualRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Could not find RelUCIRelatedIndividual with id : " + id));
    }

}
