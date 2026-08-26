package com.arthus.repositories.contextuel;

import com.arthus.entitys.contextuel.Piece;
import com.arthus.entitys.enums.ContexteEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

/*
 * Chargement brut des pieces par (contexte, entites). Le tri et les filtres
 * "en attente / recue / annulee" sont dans PieceService.
 *
 * Les index utiles sont (ENTITE, NUMBENE) et (IDREPARTITION, ENTITE) : filtrer
 * sur ENTITE est donc toujours selectif, contrairement a un filtre sur le seul
 * CONTEXTE.
 */
public interface PieceRepository extends JpaRepository<Piece, Long> {

    @Query("""
           select p
           from Piece p
             left join fetch p.destinataire
             left join fetch p.beneficiaire
           where p.contexte = :contexte
             and p.entite in :entites
           order by p.entite, p.nopiece, p.idpiece
           """)
    List<Piece> findByContexteEtEntites(@Param("contexte") ContexteEnum contexte,
                                        @Param("entites") Collection<Long> entites);

    /*
     * Variante pour les pieces d'un beneficiaire precis : en contexte 17, ENTITE
     * reste le NOSIN et c'est NUMBENE qui discrimine.
     */
    @Query("""
           select p
           from Piece p
             left join fetch p.destinataire
           where p.contexte = :contexte
             and p.entite in :entites
             and p.numbene = :numbene
           order by p.entite, p.nopiece, p.idpiece
           """)
    List<Piece> findByContexteEntitesEtBeneficiaire(@Param("contexte") ContexteEnum contexte,
                                                    @Param("entites") Collection<Long> entites,
                                                    @Param("numbene") Long numbene);
}
