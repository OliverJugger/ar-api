package com.arthus.services.contextuel;

import com.arthus.entitys.contextuel.CleContexte;
import com.arthus.entitys.contextuel.EntiteContextuelle;
import com.arthus.entitys.enums.ContexteEnum;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/*
 * Socle commun aux services des tables generiques (CORRESPONDANT, PIECES,
 * RAPPEL). Il porte les trois problemes que ces tables posent a chaque fois, pour
 * que les sous-classes n'aient a coder que le metier :
 *
 * 1. La conversion NOSIN -> ENTITE, deleguee a CleContexte, avec la version
 *    tolerante : un NOSIN non numerique donne un resultat vide, pas une
 *    exception qui remonte jusqu'a l'IHM.
 *
 * 2. Le N+1. Des qu'on affiche une liste de sinistres, resoudre les elements
 *    contextuels un par un coute une requete par ligne. Les methodes "parLot"
 *    ramenent tout en une passe et rendent une Map prete a etre consommee par
 *    l'assembleur de DTO.
 *
 * 3. La limite Oracle de 1000 elements dans un IN. Les lots sont decoupes en
 *    tranches de TAILLE_LOT, de facon transparente pour l'appelant.
 *
 * Les sous-classes n'implementent que charger() : une delegation au repository.
 */
public abstract class ServiceContextuelAbstract<T extends EntiteContextuelle> {

    /*
     * Oracle refuse au-dela de 1000 valeurs dans un IN. On garde de la marge pour
     * les eventuels parametres additionnels de la requete.
     */
    protected static final int TAILLE_LOT = 900;

    /* Seul point a implementer : l'appel au repository. */
    protected abstract List<T> charger(ContexteEnum contexte, Collection<Long> entites);

    /* ------------------------------------------------------------------ */
    /* Acces unitaire                                                      */
    /* ------------------------------------------------------------------ */

    public List<T> rechercher(CleContexte cle) {
        Objects.requireNonNull(cle, "cle obligatoire");
        return charger(cle.contexte(), List.of(cle.entite()));
    }

    /*
     * Version a partir d'un NOSIN : tolerante, elle rend une liste vide si le
     * numero n'est pas convertible.
     */
    public List<T> rechercherParNosin(ContexteEnum contexte, String nosin) {
        return CleContexte.optionnelle(contexte, nosin)
                .map(this::rechercher)
                .orElseGet(List::of);
    }

    /* ------------------------------------------------------------------ */
    /* Acces par lot : une seule requete pour toute une page               */
    /* ------------------------------------------------------------------ */

    public Map<Long, List<T>> rechercherParLot(ContexteEnum contexte, Collection<Long> entites) {
        if (entites == null || entites.isEmpty()) {
            return Map.of();
        }
        List<Long> distinctes = new LinkedHashSet<>(entites).stream()
                .filter(Objects::nonNull)
                .toList();

        Map<Long, List<T>> resultat = new LinkedHashMap<>();
        for (int debut = 0; debut < distinctes.size(); debut += TAILLE_LOT) {
            List<Long> tranche = distinctes.subList(debut, Math.min(debut + TAILLE_LOT, distinctes.size()));
            charger(contexte, tranche).forEach(
                    element -> resultat.computeIfAbsent(element.getEntite(), c -> new java.util.ArrayList<>())
                                       .add(element));
        }
        return resultat;
    }

    /*
     * Variante indexee par NOSIN plutot que par ENTITE : c'est ce que manipule
     * l'assembleur de DTO, qui n'a pas a connaitre la conversion numerique.
     * Les NOSIN non convertibles sont simplement absents de la Map.
     */
    public Map<String, List<T>> rechercherParLotDeNosin(ContexteEnum contexte, Collection<String> nosins) {
        if (nosins == null || nosins.isEmpty()) {
            return Map.of();
        }
        Map<Long, String> nosinParEntite = nosins.stream()
                .filter(Objects::nonNull)
                .distinct()
                .flatMap(nosin -> CleContexte.versEntiteOptionnelle(nosin)
                        .map(entite -> Map.entry(entite, nosin))
                        .stream())
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue, (a, b) -> a,
                                          LinkedHashMap::new));

        Map<Long, List<T>> parEntite = rechercherParLot(contexte, nosinParEntite.keySet());

        Map<String, List<T>> resultat = new LinkedHashMap<>();
        parEntite.forEach((entite, elements) -> resultat.put(nosinParEntite.get(entite), elements));
        return resultat;
    }

    /* Utilitaire pour les sous-classes : filtrer sans reecrire le stream. */
    protected List<T> filtrer(List<T> elements, java.util.function.Predicate<T> predicat) {
        return elements.stream().filter(predicat).toList();
    }
}
