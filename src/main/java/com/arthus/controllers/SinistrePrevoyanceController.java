package com.arthus.controllers;

import com.arthus.services.SinistrePrevoyanceService;
import com.arthus.generated.api.DossierSinistreApi;
import com.arthus.generated.api.SinistreApi;
import com.arthus.repositories.specification.criteria.DossierSinistreSearchCriteria;
import com.arthus.generated.model.SinistreDetailsDTO;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class SinistrePrevoyanceController implements SinistreApi {

    private final SinistrePrevoyanceService sinistrePrevoyanceService;

    @Override
    public ResponseEntity<SinistreDetailsDTO> getSinistreDetails(String idSinistre) {
        return ResponseEntity.ok(sinistrePrevoyanceService.getSinistrePrevoyanceDetails(idSinistre));
    }
   
}