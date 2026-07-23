package com.bdl.epbs_fund_api.services.impl;

import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_FULL_ACCESS;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.mappings.LegalPersonMapper;
import com.bdl.epbs_fund_api.model.LegalPersonDTO;
import com.bdl.epbs_fund_api.model.entities.LegalPerson;
import com.bdl.epbs_fund_api.repositories.LegalPersonRepository;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.services.access.HasAccess;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class LegalPersonService {

    private final LegalPersonRepository legalPersonRepository;

    private final LegalPersonMapper legalPersonMapper;

	private final TechnicalAccessService technicalAccessService;

    public List<LegalPersonDTO> searchLegalPersons(String nameContains, Integer limit) {
        Pageable pageable = Optional.ofNullable(limit)
                .map(lim -> PageRequest.of(0, lim))
                .orElse(PageRequest.of(0, 20));

        return Optional.ofNullable(nameContains)
                .map(param -> URLDecoder.decode(param, StandardCharsets.UTF_8))
                .map(String::trim)
                .map(param -> legalPersonRepository.findByLegalNameContaining(param, pageable))
                .map(legalPersonMapper::mapToDtoList)
                .orElse(Collections.emptyList());
    }

    @HasAccess(EPBS_ROLE_FULL_ACCESS)
    public List<LegalPersonDTO> getAllLegalPersons() {
    	return legalPersonMapper.mapToDtoList(legalPersonRepository.findAll(PageRequest.of(0, 100)).getContent());
    }
    
    public LegalPerson getLegalPersonInternal(Integer legalPersonId) {
        return legalPersonRepository.findById(legalPersonId).orElseThrow(() -> new ResourceNotFoundException("Could not find LegalPerson with id : " + legalPersonId));
    }

    public LegalPersonDTO getLegalPerson(Integer legalPersonId) {
        return legalPersonRepository.findById(legalPersonId)
                .map(legalPersonMapper::mapToDto)
                .orElse(null);
    }

    public LegalPersonDTO createLegalPerson(LegalPersonDTO legalPersonDTO) {

    	LegalPerson legalPerson = legalPersonMapper.mapToEntity(legalPersonDTO, null);
    	LegalPerson legalPersonSaved = legalPersonRepository.save(legalPerson);

		technicalAccessService.updateTechnicalTables(legalPersonSaved.getId(), Constants.INTL_ID_ELEM_LEG_PERS);
        
		return legalPersonMapper.mapToDto(legalPersonSaved);
    }

    public LegalPersonDTO updateLegalPerson(LegalPersonDTO legalPersonDTO) {
    	return legalPersonRepository.findById(Integer.valueOf(legalPersonDTO.getId()))
	    	.map(lpActual -> legalPersonMapper.mapToEntity(legalPersonDTO, lpActual))
	    	.map(legalPersonRepository::save)
            .map(legalPersonMapper::mapToDto)
            .orElse(null);
    }

    public LegalPersonDTO unlinkTask(Integer lpId) {
        return legalPersonRepository.findById(lpId)
                .map(lp -> {
                    lp.setTaskUid(null);
                    return lp;
                })
                .map(legalPersonRepository::save)
                .map(legalPersonMapper::mapToDto)
                .orElse(null);
    }
    
}
