package com.arthus.entitys.contextuel;

import com.arthus.entitys.enums.ContexteEnum;

import java.util.Objects;
import java.util.Optional;

/*
 * Le couple (CONTEXTE, ENTITE) qui identifie l'objet vise par un correspondant,
 * une piece ou un rappel.
 *
 * C'est ici, et NULLE PART AILLEURS, que se fait la conversion du NOSIN :
 * SNTR_PREV.NOSIN est un VARCHAR2(9) alors que ENTITE est un NUMBER. Le legacy
 * fait TO_NUMBER(nosin) dans V_CORRES, V_BENE_JUSTIF_SIN, F_SEL_DEST_DCPT... et
 * plante donc sur un numero non numerique. On centralise pour ne pas dupliquer la
 * regle a chaque table generique ajoutee.
 */
public record CleContexte(ContexteEnum contexte, Long entite) {

    public CleContexte {
        Objects.requireNonNull(contexte, "contexte obligatoire");
        Objects.requireNonNull(entite, "entite obligatoire");
    }

    /* --- Fabriques par contexte : elles nomment la nature de la cle --- */

    // Correspondants et pieces rattaches au sinistre lui-meme
    public static CleContexte sinistrePrevoyance(String nosin) {
        return new CleContexte(ContexteEnum.SINISTRE_PREVOYANCE, versEntite(nosin));
    }

    // Rappels : PK_WS_WEB_MAJ_BACK bascule le rappel en contexte 16, entite = nosin
    public static CleContexte dossierSinistrePrevoyance(String nosin) {
        return new CleContexte(ContexteEnum.DOSSIER_SINISTRE_PREVOYANCE, versEntite(nosin));
    }

    /*
     * Pieces du beneficiaire : le contexte change (17) mais ENTITE reste le NOSIN.
     * Cf. PK_WS_WEB_BACK : "WHERE p.entite = p_nosin AND p.contexte = 17".
     * C'est NUMBENE qui distingue le beneficiaire, pas l'entite.
     */
    public static CleContexte beneficiaireSinistrePrevoyance(String nosin) {
        return new CleContexte(ContexteEnum.BENEFICIAIRE_SINISTRE_PREVOYANCE, versEntite(nosin));
    }

    public static CleContexte contrat(Long numgar) {
        return new CleContexte(ContexteEnum.CONTRAT, numgar);
    }

    public static CleContexte adhesion(Long idadhesion) {
        return new CleContexte(ContexteEnum.ADHESION, idadhesion);
    }

    /* --- Conversion du NOSIN --- */

    /*
     * Version stricte : leve si le NOSIN n'est pas numerique. A utiliser quand un
     * NOSIN invalide traduit un bug amont plutot qu'une donnee absente.
     */
    public static Long versEntite(String nosin) {
        return versEntiteOptionnelle(nosin).orElseThrow(
                () -> new IllegalArgumentException("NOSIN non convertible en ENTITE : " + nosin));
    }

    /*
     * Version tolerante : renvoie vide plutot que de lever. Les services l'utilisent
     * pour qu'un NOSIN douteux donne une liste vide au lieu d'une 500.
     */
    public static Optional<Long> versEntiteOptionnelle(String nosin) {
        if (nosin == null || nosin.isBlank()) {
            return Optional.empty();
        }
        try {
            return Optional.of(Long.valueOf(nosin.trim()));
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }

    public static Optional<CleContexte> optionnelle(ContexteEnum contexte, String nosin) {
        return versEntiteOptionnelle(nosin).map(entite -> new CleContexte(contexte, entite));
    }
}
