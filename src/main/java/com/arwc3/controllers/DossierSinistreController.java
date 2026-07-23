package com.arwc3.controllers;

import com.arwc3.services.DossierSinistreService;
import com.arwc3.generated.api.DossierSinistreApi;
import com.arwc3.generated.model.PageDossierSinistreDTO;
import com.arwc3.repositories.specification.criteria.DossierSinistreSearchCriteria;
import com.arwc3.generated.model.DossierSinistreCriteriaDTO;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class DossierSinistreController implements DossierSinistreApi {

    private final DossierSinistreService dossierSinistreService;

    @Override
    public ResponseEntity<PageDossierSinistreDTO> rechercherDossiersSinistre(Integer page, Integer size, DossierSinistreCriteriaDTO searchCriteriaDTO) {
        DossierSinistreSearchCriteria searchCriteria =  DossierSinistreSearchCriteria
            .builder()
            .anterieur(searchCriteriaDTO.getAnterieur())
            .finNull(searchCriteriaDTO.getFinNull())
            .prenomIndividuContains(searchCriteriaDTO.getPrenomIndividuContains())
            .nomIndividuContains(searchCriteriaDTO.getNomIndividuContains())
            .debutFrom(searchCriteriaDTO.getDebutFrom())
            .debutTo(searchCriteriaDTO.getDebutTo())
            .finFrom(searchCriteriaDTO.getFinFrom())
            .finTo(searchCriteriaDTO.getFinTo())
            .build();
        return ResponseEntity.ok(dossierSinistreService.getDossiersSinistre(page, size, searchCriteria));
    }
}
