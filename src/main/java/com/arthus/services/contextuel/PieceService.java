package com.arthus.services.contextuel;

import com.arthus.entitys.contextuel.CleContexte;
import com.arthus.entitys.contextuel.Piece;
import com.arthus.entitys.enums.ContexteEnum;
import com.arthus.repositories.contextuel.PieceRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Collection;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/*
 * Les pieces justificatives demandees sur un sinistre.
 *
 * Le cycle de vie d'une demande n'est ecrit nulle part dans le schema : il se
 * deduit des filtres que PK_MAIL applique en boucle. On le fixe ici, une fois :
 *   en attente  = DATERECEP nulle ET DATANNUL nulle
 *   recue       = DATERECEP renseignee
 *   annulee     = DATANNUL renseignee
 *   relancable  = en attente ET (DATEREL ou DATEAVIS) renseignee
 * Les DTO et les ecrans consomment ces methodes, ils ne refont pas le test.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PieceService extends ServiceContextuelAbstract<Piece> {

    private final PieceRepository pieceRepository;

    @Override
    protected List<Piece> charger(ContexteEnum contexte, Collection<Long> entites) {
        return pieceRepository.findByContexteEtEntites(contexte, entites);
    }

    /* ------------------------------------------------------------------ */
    /* Lecture                                                             */
    /* ------------------------------------------------------------------ */

    // Pieces rattachees au sinistre lui-meme (contexte 15)
    public List<Piece> duSinistre(String nosin) {
        return rechercherParNosin(ContexteEnum.SINISTRE_PREVOYANCE, nosin);
    }

    /*
     * Pieces rattachees au beneficiaire (contexte 17). ENTITE reste le NOSIN,
     * NUMBENE discrimine le beneficiaire - d'ou le filtre supplementaire, porte
     * par la requete plutot que par un stream, pour rester selectif sur l'index
     * (ENTITE, NUMBENE).
     */
    public List<Piece> duBeneficiaire(String nosin, Long numbene) {
        return CleContexte.optionnelle(ContexteEnum.BENEFICIAIRE_SINISTRE_PREVOYANCE, nosin)
                .map(cle -> pieceRepository.findByContexteEntitesEtBeneficiaire(
                        cle.contexte(), List.of(cle.entite()), numbene))
                .orElseGet(List::of);
    }

    // Toutes les pieces du sinistre, les deux contextes confondus
    public List<Piece> toutesDuSinistre(String nosin) {
        return java.util.stream.Stream
                .concat(duSinistre(nosin).stream(),
                        rechercherParNosin(ContexteEnum.BENEFICIAIRE_SINISTRE_PREVOYANCE, nosin).stream())
                .toList();
    }

    public List<Piece> enAttente(String nosin) {
        return filtrer(toutesDuSinistre(nosin), PieceService::estEnAttente);
    }

    public List<Piece> bloquantesEnAttente(String nosin) {
        return filtrer(enAttente(nosin), p -> "O".equals(p.getBloc()));
    }

    /*
     * Transposition de PK_PRDG_FONCT.F_get_piece :
     *     SELECT max(daterecep) FROM PIECES
     *      WHERE nopiece = :nopiece AND CONTEXTE = 15 AND entite = :nosin
     *        AND NVL(daterecep, :date + 1) <= :date
     * Le NVL sert uniquement a ecarter les pieces non recues : cela revient a
     * prendre la derniere reception anterieure ou egale a la date d'observation.
     */
    public Optional<LocalDate> derniereReception(String nosin, Integer nopiece, LocalDate aDate) {
        return duSinistre(nosin).stream()
                .filter(p -> nopiece.equals(p.getNopiece()))
                .map(Piece::getDaterecep)
                .filter(java.util.Objects::nonNull)
                .filter(date -> !date.isAfter(aDate))
                .max(Comparator.naturalOrder());
    }

    /* ------------------------------------------------------------------ */
    /* Lecture par lot                                                     */
    /* ------------------------------------------------------------------ */

    public Map<String, List<Piece>> parSinistres(Collection<String> nosins) {
        return rechercherParLotDeNosin(ContexteEnum.SINISTRE_PREVOYANCE, nosins);
    }

    /*
     * Le compte de pieces en attente par sinistre, en une requete : typiquement
     * la pastille d'une liste de dossiers.
     */
    public Map<String, Long> compteEnAttenteParSinistre(Collection<String> nosins) {
        Map<String, Long> resultat = new LinkedHashMap<>();
        parSinistres(nosins).forEach((nosin, pieces) ->
                resultat.put(nosin, pieces.stream().filter(PieceService::estEnAttente).count()));
        return resultat;
    }

    /* ------------------------------------------------------------------ */
    /* Regles de cycle de vie - un seul endroit                            */
    /* ------------------------------------------------------------------ */

    public static boolean estEnAttente(Piece piece) {
        return piece.getDaterecep() == null && piece.getDatannul() == null;
    }

    public static boolean estRecue(Piece piece) {
        return piece.getDaterecep() != null;
    }

    public static boolean estAnnulee(Piece piece) {
        return piece.getDatannul() != null;
    }

    public static boolean aEteRelancee(Piece piece) {
        return piece.getNbrel() != null && piece.getNbrel() > 0;
    }
}
