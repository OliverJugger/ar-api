package com.arwc3.controllers;

import com.arwc3.services.DossierSinistreService;
import com.arwc3.generated.api.DossierSinistreApi;
import com.arwc3.generated.model.PageDossierSinistreDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class DossierSinistreController implements DossierSinistreApi {

    private final DossierSinistreService dossierSinistreService;

    @Override
    public ResponseEntity<PageDossierSinistreDTO> getDossiersSinistre(Integer page, Integer size) {
        return ResponseEntity.ok(dossierSinistreService.getDossiersSinistre(page, size));
    }
}
