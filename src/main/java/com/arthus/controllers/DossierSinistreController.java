package com.arthus.controllers;

import com.arthus.services.DossierSinistreService;
import com.arthus.generated.api.DossierSinistreApi;
import com.arthus.generated.model.PageDossierSinistreDTO;
import com.arthus.repositories.specification.criteria.DossierSinistreSearchCriteria;
import com.arthus.generated.model.DossierSinistreCriteriaDTO;
import com.arthus.generated.model.DossierSinistreDetailsDTO;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class DossierSinistreController implements DossierSinistreApi {

    private final DossierSinistreService dossierSinistreService;

    @Override
    public ResponseEntity<DossierSinistreDetailsDTO> getDossierSinistreDetails(String idDossier) {
        return ResponseEntity.ok(dossierSinistreService.getDossierSinistreDetails(idDossier));
    }

    @Override
    public ResponseEntity<PageDossierSinistreDTO> rechercherDossiersSinistre(Integer page, Integer size, DossierSinistreCriteriaDTO searchCriteriaDTO) {
        DossierSinistreSearchCriteria searchCriteria =  DossierSinistreSearchCriteria
            .builder()
            .numeroDossierContains(searchCriteriaDTO.getNumeroDossierContains())
            .numeroAssureContains(searchCriteriaDTO.getNumeroAssureContains())
            .numeroContrat(searchCriteriaDTO.getNumeroContrat())
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
