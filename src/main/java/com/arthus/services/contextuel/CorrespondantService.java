package com.arthus.services.contextuel;

import com.arthus.entitys.contextuel.CleContexte;
import com.arthus.entitys.Individu;
import com.arthus.entitys.contextuel.Correspondant;
import com.arthus.entitys.enums.ContexteEnum;
import com.arthus.entitys.enums.TypeCorrespondantEnum;
import com.arthus.repositories.contextuel.CorrespondantRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/*
 * Les correspondants d'un sinistre, d'un contrat ou de tout autre objet metier.
 *
 * Toute la connaissance du legacy est ici plutot que dans l'entite ou dans un
 * mapper :
 *   - le correspondant par defaut se lit sur DEFAUT_SNTR = 'O' (c'est
 *     l'asterisque de V_CORRES, et le critere de F_SEL_DEST_DCPT) ;
 *   - la qualite du correspondant est portee par NAT_CORRES, pas par TYPE_CORRES ;
 *   - l'unicite metier porte sur (CONTEXTE, ENTITE, NAT_CORRES, NUMCORRES) et
 *     n'est garantie par aucune contrainte : c'est a la creation de la tenir.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CorrespondantService extends ServiceContextuelAbstract<Correspondant> {

    private final CorrespondantRepository correspondantRepository;

    /* Injectee pour que la creation reste testable sans figer l'horloge systeme. */
    private final Clock horloge;

    @Override
    protected List<Correspondant> charger(ContexteEnum contexte, Collection<Long> entites) {
        return correspondantRepository.findByContexteEtEntites(contexte, entites);
    }

    /* ------------------------------------------------------------------ */
    /* Lecture                                                             */
    /* ------------------------------------------------------------------ */

    public List<Correspondant> duSinistre(String nosin) {
        return rechercherParNosin(ContexteEnum.SINISTRE_PREVOYANCE, nosin);
    }

    public List<Correspondant> duContrat(Long numgar) {
        return rechercher(CleContexte.contrat(numgar));
    }

    /*
     * Le correspondant par defaut du sinistre. F_SEL_DEST_DCPT le selectionne
     * exactement ainsi : contexte 15, entite = nosin, DEFAUT_SNTR = 'O'.
     * Rien n'empeche la base d'en contenir plusieurs - on prend le premier, la
     * liste etant triee par NAT_CORRES puis ID_CORRES.
     */
    public Optional<Correspondant> parDefaut(String nosin) {
        return duSinistre(nosin).stream()
                .filter(CorrespondantService::estParDefaut)
                .findFirst();
    }

    public List<Correspondant> parQualite(String nosin, TypeCorrespondantEnum qualite) {
        return filtrer(duSinistre(nosin), c -> c.getNatCorres() == qualite);
    }

    public Optional<Correspondant> beneficiaire(String nosin) {
        return parQualite(nosin, TypeCorrespondantEnum.BENEFICIAIRE).stream().findFirst();
    }

    /* ------------------------------------------------------------------ */
    /* Lecture par lot : a utiliser des qu'on affiche une liste            */
    /* ------------------------------------------------------------------ */

    public Map<String, List<Correspondant>> parSinistres(Collection<String> nosins) {
        return rechercherParLotDeNosin(ContexteEnum.SINISTRE_PREVOYANCE, nosins);
    }

    /*
     * Le correspondant par defaut de chaque sinistre, en une requete.
     * C'est la methode a appeler depuis un assembleur de DTO de liste : appeler
     * parDefaut() dans une boucle coute une requete par ligne affichee.
     */
    public Map<String, Correspondant> parDefautPourSinistres(Collection<String> nosins) {
        Map<String, Correspondant> resultat = new LinkedHashMap<>();
        parSinistres(nosins).forEach((nosin, correspondants) ->
                correspondants.stream()
                        .filter(CorrespondantService::estParDefaut)
                        .findFirst()
                        .ifPresent(c -> resultat.put(nosin, c)));
        return resultat;
    }

    /* ------------------------------------------------------------------ */
    /* Ecriture                                                            */
    /* ------------------------------------------------------------------ */

    /*
     * Creation idempotente, transposition du "WHERE NOT EXISTS" que le legacy
     * recopie dans P_REPRISE_SIN_PREV*, PK_WS_WEB_MAJ_BACK, etc.
     *
     * Attention : ce controle n'est pas atomique, exactement comme dans le
     * legacy - aucune contrainte d'unicite ne protege la table. Sous forte
     * concurrence, deux appels simultanes peuvent creer un doublon. Si le besoin
     * s'en fait sentir, la vraie reponse est un index unique en base sur
     * (CONTEXTE, ENTITE, NAT_CORRES, NUMCORRES), pas un verrou applicatif.
     */
    @Transactional
    public Correspondant creerSiAbsent(CleContexte cle,
                                       Individu correspondantPersonne,
                                       TypeCorrespondantEnum qualite,
                                       Integer typeCorres,
                                       Individu interlocuteur,
                                       Integer utilisateur) {
        Long numcorres = correspondantPersonne.getNumindiv();
        Optional<Correspondant> existant = rechercher(cle).stream()
                .filter(c -> c.getNatCorres() == qualite)
                .filter(c -> numcorres.equals(c.getNumcorres()))
                .findFirst();
        if (existant.isPresent()) {
            return existant.get();
        }

        LocalDateTime maintenant = LocalDateTime.now(horloge);
        return correspondantRepository.save(Correspondant.builder()
                .contexte(cle.contexte())
                .entite(cle.entite())
                .numcorres(numcorres)
                .natCorres(qualite)
                .typeCorres(typeCorres)
                .interlocuteur(interlocuteur)
                .defautSntr("N")
                .defautPjAssu("N")
                .defautPjBene("N")
                .defautRgltBene("N")
                .creation(maintenant)
                .createur(utilisateur)
                .modification(maintenant)
                .modificateur(utilisateur)
                .build());
    }

    /* ------------------------------------------------------------------ */

    private static boolean estParDefaut(Correspondant correspondant) {
        return "O".equals(correspondant.getDefautSntr());
    }
}
