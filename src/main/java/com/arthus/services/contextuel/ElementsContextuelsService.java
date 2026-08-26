package com.arthus.services.contextuel;

import com.arthus.entitys.contextuel.Correspondant;
import com.arthus.entitys.contextuel.Piece;
import com.arthus.entitys.contextuel.Rappel;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/*
 * Facade : tout ce qui est rattache a un sinistre par (CONTEXTE, ENTITE), en un
 * seul appel. C'est le point d'entree des assembleurs de DTO - ils n'ont ni a
 * connaitre les codes contexte, ni a savoir que les rappels vivent sous deux
 * contextes, ni a convertir le NOSIN.
 *
 * Trois requetes par sinistre (correspondants, pieces, rappels), ou trois pour
 * toute une page si on passe par elementsDeSinistres().
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ElementsContextuelsService {

    private final CorrespondantService correspondantService;
    private final PieceService pieceService;
    private final RappelService rappelService;

    /* Vue agregee pour un sinistre. */
    public record ElementsDuSinistre(String nosin,
                                     List<Correspondant> correspondants,
                                     Optional<Correspondant> correspondantParDefaut,
                                     List<Piece> pieces,
                                     List<Piece> piecesEnAttente,
                                     List<Rappel> rappels) {

        public boolean aDesPiecesBloquantes() {
            return piecesEnAttente.stream().anyMatch(p -> "O".equals(p.getBloc()));
        }
    }

    public ElementsDuSinistre duSinistre(String nosin) {
        List<Correspondant> correspondants = correspondantService.duSinistre(nosin);
        List<Piece> pieces = pieceService.toutesDuSinistre(nosin);
        return new ElementsDuSinistre(
                nosin,
                correspondants,
                correspondants.stream().filter(c -> "O".equals(c.getDefautSntr())).findFirst(),
                pieces,
                pieces.stream().filter(PieceService::estEnAttente).toList(),
                rappelService.toutesDuSinistre(nosin));
    }

    /*
     * Version liste : trois requetes au total, quel que soit le nombre de
     * sinistres. A utiliser des qu'on affiche un tableau - la boucle sur
     * duSinistre() coute trois requetes PAR LIGNE.
     */
    public Map<String, ElementsDuSinistre> deSinistres(Collection<String> nosins) {
        Map<String, List<Correspondant>> correspondants = correspondantService.parSinistres(nosins);
        Map<String, List<Piece>> pieces = pieceService.parSinistres(nosins);
        Map<String, List<Rappel>> rappels = rappelService.parSinistres(nosins);

        Map<String, ElementsDuSinistre> resultat = new LinkedHashMap<>();
        for (String nosin : nosins) {
            List<Correspondant> c = correspondants.getOrDefault(nosin, List.of());
            List<Piece> p = pieces.getOrDefault(nosin, List.of());
            resultat.put(nosin, new ElementsDuSinistre(
                    nosin,
                    c,
                    c.stream().filter(x -> "O".equals(x.getDefautSntr())).findFirst(),
                    p,
                    p.stream().filter(PieceService::estEnAttente).toList(),
                    rappels.getOrDefault(nosin, List.of())));
        }
        return resultat;
    }
}
