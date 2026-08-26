package com.arthus.services;

import com.arthus.entitys.GarantieContratRef;
import com.arthus.repositories.GarantieContratRefRepository;
import com.arthus.repositories.lecture.GarantieSinistreView;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/*
 * Les garanties d'un sinistre.
 *
 * La regle metier portee ici : une garantie est rattachee au sinistre par une
 * REPARTITION valide, et doit elle-meme etre valide. Ce double filtre etait
 * autrefois duplique entre l'entite et les requetes ; il n'existe plus qu'ici et
 * dans les requetes du repository.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class GarantieSinistreService {

    private final GarantieContratRefRepository garantieRepository;

    public List<GarantieContratRef> getGarantiesFromSinistre(String idSinistre) {
        return garantieRepository.findByNosin(idSinistre);
    }
	
	// Les garanties valides du contrat, hors contexte sinistre
    public List<GarantieContratRef> getGarantiesFromContrat(Long idContrat) {
        return garantieRepository.findByNumgarAndValideOrderByNumfor(idContrat, "O");
    }

    /*
     * Garanties enrichies des dates de couverture (ADHESION.DATAPLI / DATPER),
     * cas "groupe de garanties" (PREV CARCO) inclus.
     * numindivAssure est le NUMINDIV du dossier : c'etait le :tronc.numindiv de
     * l'ecran Forms, et il n'est utilise que par le 2e terme de l'UNION.
     */
    public List<GarantieSinistreView> avecDates(String nosin, Long numindivAssure) {
        return garantieRepository.findAvecDatesParNosin(nosin, numindivAssure);
    }
    

}
