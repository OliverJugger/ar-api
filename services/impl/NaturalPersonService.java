package com.bdl.epbs_fund_api.services.impl;

import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_FULL_ACCESS;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_NP_CREATE;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_NP_UPDATE_STATIC_DATA;
import static com.bdl.epbs_fund_api.constants.Constants.INTL_ID_ELEM_NAT_PERS;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.NaturalPersonMapper;
import com.bdl.epbs_fund_api.model.NaturalPersonDTO;
import com.bdl.epbs_fund_api.model.entities.NaturalPerson;
import com.bdl.epbs_fund_api.repositories.NaturalPersonRepository;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.services.access.HasAccess;
import com.bdl.epbs_fund_api.utils.JaccardSimilarityUtil;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;


@Service
@RequiredArgsConstructor
public class NaturalPersonService {

    private final NaturalPersonRepository naturalPersonRepository;

    private final NaturalPersonMapper naturalPersonMapper;

    private final TechnicalAccessService technicalAccessService;

    public List<NaturalPersonDTO> searchNaturalPersons(String firstName, String lastName, String searchRemaining, Integer limit) {
        return Optional.ofNullable(naturalPersonRepository.findNaturalPersonByFirstNameContainsOrLastNameContainsOrFirstNameContainsOrLastNameContains(firstName, lastName, lastName, firstName,  PageRequest.of(0, Integer.MAX_VALUE)))
        		.map(nps -> sortBySearch(nps, firstName + lastName + searchRemaining))
        		.map(list -> list.subList(0, Math.min(limit, list.size())))
                .map(naturalPersonMapper::toDtoList)
                .orElse(Collections.emptyList());
    }

    @HasAccess(EPBS_ROLE_NP_CREATE)
    public NaturalPersonDTO createNaturalPerson(NaturalPersonDTO naturalPersonDTO) {
        return Optional.ofNullable(naturalPersonDTO)
                .map(naturalPersonMapper::toEntity)
                .map(naturalPersonRepository::save)
                .map(np -> {
                    technicalAccessService.updateTechnicalTables(np.getId(), INTL_ID_ELEM_NAT_PERS);
                    return np;
                })
                .map(naturalPersonMapper::toDto)
                .orElse(null);
    }

    @HasAccess(EPBS_ROLE_NP_UPDATE_STATIC_DATA)
    public NaturalPersonDTO updateNaturalPerson(NaturalPersonDTO naturalPersonDTO) {
        return Optional.ofNullable(naturalPersonDTO)
                .map(naturalPersonMapper::toEntity)
                .map(naturalPersonRepository::save)
                .map(naturalPersonMapper::toDto)
                .orElse(null);
    }

    public NaturalPersonDTO findNaturalPersonById(Integer naturalPersonId) {
        return Optional.ofNullable(naturalPersonId)
                .flatMap(np -> naturalPersonRepository.findById(naturalPersonId))
                .map(naturalPersonMapper::toDto)
                .orElse(null);
    }
    
    public NaturalPerson getNaturalPersonByIdInternal(Integer naturalPersonId) {
    	return naturalPersonRepository.findById(naturalPersonId).orElseThrow(() -> new ResourceNotFoundException("Could not find natural person with id : " + naturalPersonId));
    }

    public NaturalPersonDTO unlinkTask(Integer npId) {
        return naturalPersonRepository.findById(npId)
                .map(np -> {
                    np.setTaskUid(null);
                    return np;
                })
                .map(naturalPersonRepository::save)
                .map(naturalPersonMapper::toDto)
                .orElse(null);
    }
    
    @HasAccess(EPBS_ROLE_FULL_ACCESS)
    public List<NaturalPersonDTO> findAllNaturalPersons() {
    	return Optional.ofNullable(naturalPersonRepository.findAll(PageRequest.of(0, 100)).getContent())
                .map(naturalPersonMapper::toDtoList)
                .orElse(Collections.emptyList());
    }
    
    private List<NaturalPerson> sortBySearch(List<NaturalPerson> naturalPersons, String search) {
    	return naturalPersons.stream()
        		.sorted(getJaccardSimilarityComparator(search))
        		.toList();
    }
    
    private static String getNaturalPersonName(NaturalPerson np) {
    	return np.getFirstName() + np.getLastName();
    }
    
    private static Comparator<NaturalPerson> getJaccardSimilarityComparator(String query) {
        return (np1, np2) -> Double.compare(JaccardSimilarityUtil.calculateJaccardSimilarity(query, getNaturalPersonName(np2)), JaccardSimilarityUtil.calculateJaccardSimilarity(query, getNaturalPersonName(np1)));
    }
    
}
