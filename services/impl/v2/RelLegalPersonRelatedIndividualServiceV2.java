package com.bdl.epbs_fund_api.services.impl.v2;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.relations.v2.RelLegalPersonRelatedIndividualV2;
import com.bdl.epbs_fund_api.repositories.v2.RelLegalPersonRelatedIndividualRepositoryV2;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RelLegalPersonRelatedIndividualServiceV2 {

    private final RelLegalPersonRelatedIndividualRepositoryV2 relLegalPersonRelatedIndividualRepository;

    public RelLegalPersonRelatedIndividualV2 findById(Integer id) {
    	return relLegalPersonRelatedIndividualRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Could not find RelLegalPersonRelatedIndividual with id : " + id));
    }
    
    public void deleteById(Integer id) {
        relLegalPersonRelatedIndividualRepository.deleteById(id);
    }

}
