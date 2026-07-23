package com.arwc3.services;

import java.util.List;
import com.arwc3.repositories.DossierSinistreRepository;
import com.arwc3.repositories.specification.DossierSinistreSpecification;
import com.arwc3.repositories.specification.criteria.DossierSinistreSearchCriteria;
import com.arwc3.repositories.specification.rules.dossier_sinistre.DossierSinistreRule;
import com.arwc3.generated.model.PageDossierSinistreDTO;
import com.arwc3.generated.model.DossierSinistreDTO;
import com.arwc3.mappers.DossierSinistreMapper;
import com.arwc3.entitys.DossierSinistre;

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
    public PageDossierSinistreDTO getDossiersSinistre(Integer page, Integer size, DossierSinistreSearchCriteria searchCriteria) {
        Page<DossierSinistre> dossierSinistres = dossierSinistreRepository.findAll(
                new DossierSinistreSpecification(searchCriteria, dossierSinistreRules),
                        PageRequest.of(page, size, Sort.by("debut").descending()));

        List<DossierSinistreDTO> dossierSinistreDTOs = dossierSinistreMapper.toDossierSinistreDTO(dossierSinistres.getContent());
        PageDossierSinistreDTO pageDossierSinistre = new PageDossierSinistreDTO(dossierSinistres.getNumber(), dossierSinistres.getSize(), dossierSinistres.getNumberOfElements(), dossierSinistres.getTotalElements());
        pageDossierSinistre.data(dossierSinistreDTOs);
        return pageDossierSinistre;
    }

}
