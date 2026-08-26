package com.arthus.services;

import com.arthus.entitys.Individu;
import com.arthus.entitys.GarantieContratRef;
import com.arthus.entitys.HistoriqueSinistrePrevoyance;
import com.arthus.entitys.RepartitionBene;
import com.arthus.entitys.SinistrePrevoyance;
import com.arthus.generated.model.SinistreDetailsDTO;
import com.arthus.repositories.SinistrePrevoyanceRepository;
import com.arthus.services.contextuel.CorrespondantService;
import com.arthus.services.contextuel.ElementsContextuelsService;
import com.arthus.mappers.CorrespondantMapper;
import com.arthus.mappers.GarantieContratRefMapper;
import com.arthus.mappers.HistoriqueSinistrePrevoyanceMapper;
import com.arthus.mappers.SinistreMapper;
import com.arthus.mappers.IndividuMapper;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/*
 * Facade du sinistre prevoyance : elle orchestre les services specialises, elle
 * ne contient aucune regle metier propre.
 *
 * C'est le seul endroit ou l'on assemble - chaque service specialise reste
 * utilisable seul quand un ecran n'a besoin que d'une facette. La distinction
 * compte pour le cout : vueComplete() declenche cinq requetes, alors qu'un ecran
 * qui n'affiche que les garanties n'a aucune raison d'en payer cinq.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SinistrePrevoyanceService {

    private final SinistrePrevoyanceRepository sinistreRepository;
    private final GarantieSinistreService garantieService;
    private final BeneficiaireSinistreService beneficiaireService;
    private final HistoriqueSinistreService historiqueService;
    private final CorrespondantService correspondantService;
    
    private final SinistreMapper sinistreMapper;
    private final IndividuMapper individuMapper;
    private final GarantieContratRefMapper garantieContratRefMapper;
    private final HistoriqueSinistrePrevoyanceMapper historiqueSinistrePrevoyanceMapper;  
    private final CorrespondantMapper correspondantMapper;

    public SinistreDetailsDTO getSinistrePrevoyanceDetails(String idSinistre) {
        return sinistreRepository.findAvecDossier(idSinistre)
            .map(sinistrePrev -> {
                SinistreDetailsDTO sinistrePrevDTO = sinistreMapper.toDetailsDTO(sinistrePrev);
				sinistrePrevDTO.setBeneficiaires(individuMapper.toDTO(beneficiaireService.getBeneficiairesFromSinistre(idSinistre)));
                sinistrePrevDTO.setGaranties(garantieContratRefMapper.toDTO(garantieService.getGarantiesFromSinistre(idSinistre)));
                sinistrePrevDTO.setHistorique(historiqueSinistrePrevoyanceMapper.toDTO(historiqueService.duSinistre(idSinistre)));
                sinistrePrevDTO.setCorrespondants(correspondantMapper.toDTO(correspondantService.duSinistre(idSinistre)));
				
                return sinistrePrevDTO;
            })
            .orElse(null);
    }    
}
