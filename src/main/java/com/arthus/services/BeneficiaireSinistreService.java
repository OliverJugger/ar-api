package com.arthus.services;

import com.arthus.entitys.Beneficiaire;
import com.arthus.entitys.Individu;
import com.arthus.entitys.RepartitionBene;
import com.arthus.repositories.BeneficiaireRepository;
import com.arthus.repositories.RepartitionBeneRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.function.Predicate;

/*
 * Les beneficiaires d'un sinistre.
 *
 * Deux tables, deux roles a ne pas confondre :
 *   REPARTITION_BENE = qui touche quoi sur CE sinistre (quote-part, periode).
 *   BENEFICIAIRE     = la declaration au niveau adhesion/garantie, dont le seul
 *                      apport reel est TYPE_BENE.
 * Par defaut c'est REPARTITION_BENE qu'il faut ; BENEFICIAIRE n'intervient que
 * si l'ecran affiche la qualite declaree.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BeneficiaireSinistreService {

    private final RepartitionBeneRepository repartitionBeneRepository;
    private final BeneficiaireRepository beneficiaireRepository;

    // Les personnes, dedoublonnees : un individu peut l'etre sur plusieurs garanties
    public List<Individu> getBeneficiairesFromSinistre(String idSinistre) {
        return duSinistre(idSinistre)
				.stream()
                .map(RepartitionBene::getBeneficiaire)
                .filter(Objects::nonNull)
                .filter(distinctPar(Individu::getNumindiv))
                .toList();
    }

    // La declaration BENEFICIAIRE, pour TYPE_BENE
    public List<Beneficiaire> declares(String nosin, Long numindivAssure) {
        return beneficiaireRepository.findDeclaresParNosin(nosin, numindivAssure);
    }

    public Map<String, List<RepartitionBene>> parSinistres(Collection<String> nosins) {
        if (nosins == null || nosins.isEmpty()) {
            return Map.of();
        }
        Map<String, List<RepartitionBene>> resultat = new LinkedHashMap<>();
        for (Object[] ligne : repartitionBeneRepository.findParNosins(nosins)) {
            resultat.computeIfAbsent((String) ligne[0], c -> new ArrayList<>())
                    .add((RepartitionBene) ligne[1]);
        }
        return resultat;
    }
	
	private List<RepartitionBene> duSinistre(String nosin) {
        return repartitionBeneRepository.findParNosin(nosin);
    }

    private List<RepartitionBene> duSinistrePourGarantie(String nosin, Long numfor) {
        return repartitionBeneRepository.findParNosinEtGarantie(nosin, numfor);
    }

    private static <T, K> Predicate<T> distinctPar(Function<T, K> cle) {
        Set<K> vus = new HashSet<>();
        return t -> vus.add(cle.apply(t));
    }
}
