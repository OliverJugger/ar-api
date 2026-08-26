package com.arthus.services;

import com.arthus.entitys.HistoriqueSinistrePrevoyance;
import com.arthus.entitys.enums.EtatSinistrePrevoyanceEnum;
import com.arthus.repositories.HistoriqueSinistrePrevoyanceRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/*
 * L'historique des etats d'un sinistre, et la regle qui va avec : l'etat courant
 * est la ligne de DEBUT maximum anterieure a la date d'observation. Aucune
 * colonne ne le porte, c'est un calcul - il est ici, une seule fois.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class HistoriqueSinistreService {

    private final HistoriqueSinistrePrevoyanceRepository historiqueRepository;
    private final Clock horloge;

    public List<HistoriqueSinistrePrevoyance> duSinistre(String nosin) {
        return historiqueRepository.findByNosinOrderByDebutDesc(nosin);
    }

    public Optional<HistoriqueSinistrePrevoyance> etatA(String nosin, LocalDateTime date) {
        return historiqueRepository.findAvantDate(nosin, date).stream().findFirst();
    }

    public Optional<HistoriqueSinistrePrevoyance> etatCourant(String nosin) {
        return etatA(nosin, LocalDateTime.now(horloge));
    }

    public boolean estFerme(String nosin) {
        return etatCourant(nosin)
                .map(h -> h.getEtat() == EtatSinistrePrevoyanceEnum.FERME)
                .orElse(false);
    }

    // La ligne d'ouverture : le 1er ETAT = 1, comme PK_PRDG_FONCT.P_get_histo_sinistre_prev
    public Optional<HistoriqueSinistrePrevoyance> ouverture(String nosin) {
        return historiqueRepository.findFirstByNosinAndEtatOrderByDebutAsc(
                nosin, EtatSinistrePrevoyanceEnum.EN_COURS);
    }

    /*
     * L'etat courant de plusieurs sinistres, en une requete. La liste etant triee
     * par (nosin, debut desc), la premiere ligne de chaque groupe est l'etat le
     * plus recent - on filtre ensuite sur la date d'observation.
     */
    public Map<String, HistoriqueSinistrePrevoyance> etatCourantParSinistres(Collection<String> nosins) {
        if (nosins == null || nosins.isEmpty()) {
            return Map.of();
        }
        LocalDateTime maintenant = LocalDateTime.now(horloge);
        Map<String, HistoriqueSinistrePrevoyance> resultat = new LinkedHashMap<>();
        for (HistoriqueSinistrePrevoyance h : historiqueRepository.findParNosins(nosins)) {
            if (h.getDebut() != null && !h.getDebut().isAfter(maintenant)) {
                resultat.putIfAbsent(h.getNosin(), h);
            }
        }
        return resultat;
    }

    public Map<String, List<HistoriqueSinistrePrevoyance>> parSinistres(Collection<String> nosins) {
        if (nosins == null || nosins.isEmpty()) {
            return Map.of();
        }
        Map<String, List<HistoriqueSinistrePrevoyance>> resultat = new LinkedHashMap<>();
        historiqueRepository.findParNosins(nosins).forEach(h ->
                resultat.computeIfAbsent(h.getNosin(), c -> new ArrayList<>()).add(h));
        return resultat;
    }
}
