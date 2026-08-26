package com.arthus.services;

import java.util.List;

import com.arthus.repositories.DossierSinistreRepository;
import com.arthus.repositories.specification.DossierSinistreSpecification;
import com.arthus.repositories.specification.criteria.DossierSinistreSearchCriteria;
import com.arthus.repositories.specification.rules.dossier_sinistre.DossierSinistreRule;
import com.arthus.generated.model.PageDossierSinistreDTO;
import com.arthus.generated.model.DossierSinistreDTO;
import com.arthus.generated.model.DossierSinistreDetailsDTO;
import com.arthus.mappers.DossierSinistreMapper;
import com.arthus.entitys.DossierSinistre;

import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class DossierSinistreService {

    private final List<DossierSinistreRule> dossierSinistreRules;
    private final DossierSinistreRepository dossierSinistreRepository;
    private final DossierSinistreMapper dossierSinistreMapper;

    @Transactional(readOnly = true)
    public DossierSinistreDetailsDTO getDossierSinistreDetails(String idDossier) {
        DossierSinistre dossierSinistre = dossierSinistreRepository.findById(idDossier).orElse(null);
        return dossierSinistreMapper.toDossierSinistreDetailsDTO(dossierSinistre);
    }

    @Transactional(readOnly = true)
    public PageDossierSinistreDTO getDossiersSinistre(Integer page, Integer size, DossierSinistreSearchCriteria searchCriteria) {
        Page<DossierSinistre> dossierSinistres = dossierSinistreRepository.findAll(
                    new DossierSinistreSpecification(searchCriteria, dossierSinistreRules), PageRequest.of(page, size, Sort.by("debut").descending()));
        List<DossierSinistreDTO> dossierSinistreDTOs = dossierSinistreMapper.toDossierSinistreDTO(dossierSinistres.getContent());
        PageDossierSinistreDTO pageDossierSinistre = new PageDossierSinistreDTO(dossierSinistres.getNumber(), dossierSinistres.getSize(), dossierSinistres.getNumberOfElements(), dossierSinistres.getTotalElements());
        pageDossierSinistre.data(dossierSinistreDTOs);
        return pageDossierSinistre;
    }

}
