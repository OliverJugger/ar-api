package com.arthus.services.contextuel;

import com.arthus.entitys.contextuel.Rappel;
import com.arthus.entitys.enums.ContexteEnum;
import com.arthus.repositories.contextuel.RappelRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

/*
 * Les rappels rattaches a un sinistre.
 *
 * Particularite : deux contextes coexistent pour un meme NOSIN.
 *   SINISTRE_PREVOYANCE (15)         - le rappel d'origine
 *   DOSSIER_SINISTRE_PREVOYANCE (16) - apres bascule par PK_WS_WEB_MAJ_BACK,
 *                                      qui fait "UPDATE RAPPEL SET entite = o_numsin,
 *                                      contexte = 16" avec le commentaire
 *                                      "pour dossier sinistre prevoy"
 * Un ecran qui n'interrogerait que le contexte 15 raterait donc les rappels
 * bascules : d'ou toutesDuSinistre(), a preferer par defaut.
 *
 * ETAT, TYPE et ORIGINE ne sont pas typables depuis le dump : pas de filtre
 * metier invente ici, seulement des acces parametres.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RappelService extends ServiceContextuelAbstract<Rappel> {

    private final RappelRepository rappelRepository;

    @Override
    protected List<Rappel> charger(ContexteEnum contexte, Collection<Long> entites) {
        return rappelRepository.findByContexteEtEntites(contexte, entites);
    }

    public List<Rappel> duSinistre(String nosin) {
        return rechercherParNosin(ContexteEnum.SINISTRE_PREVOYANCE, nosin);
    }

    public List<Rappel> duDossierSinistre(String nosin) {
        return rechercherParNosin(ContexteEnum.DOSSIER_SINISTRE_PREVOYANCE, nosin);
    }

    // Les deux contextes reunis, tries du plus recent au plus ancien
    public List<Rappel> toutesDuSinistre(String nosin) {
        return java.util.stream.Stream.concat(duSinistre(nosin).stream(), duDossierSinistre(nosin).stream())
                .sorted(Comparator.comparing(Rappel::getDateeffet,
                                             Comparator.nullsLast(Comparator.reverseOrder())))
                .toList();
    }

    public List<Rappel> parEtat(String nosin, Integer etat) {
        return filtrer(toutesDuSinistre(nosin), r -> Objects.equals(etat, r.getEtat()));
    }

    public List<Rappel> parType(String nosin, Integer type) {
        return filtrer(toutesDuSinistre(nosin), r -> Objects.equals(type, r.getType()));
    }

    public Optional<Rappel> lePlusRecent(String nosin) {
        return toutesDuSinistre(nosin).stream().findFirst();
    }

    public Map<String, List<Rappel>> parSinistres(Collection<String> nosins) {
        return rechercherParLotDeNosin(ContexteEnum.SINISTRE_PREVOYANCE, nosins);
    }
}
