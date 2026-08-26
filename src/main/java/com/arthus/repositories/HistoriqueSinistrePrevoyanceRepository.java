package com.arthus.repositories;

import com.arthus.entitys.HistoriqueSinistrePrevoyance;
import com.arthus.entitys.enums.EtatSinistrePrevoyanceEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

/*
 * Repository de HISTO_SNTR_PREV, cle composite (NOSIN, DEBUT).
 *
 * L'etat courant n'est pas une colonne : c'est la ligne de DEBUT maximum
 * anterieure a la date d'observation. PK_EXTRACTION_AUTO l'ecrit ainsi :
 *   histo.debut = (select max(h.debut) from histo_sntr_prev h
 *                   where h.nosin = s.nosin and debut <= :date)
 */
public interface HistoriqueSinistrePrevoyanceRepository
        extends JpaRepository<HistoriqueSinistrePrevoyance,
                              HistoriqueSinistrePrevoyance.HistoriqueSinistrePrevoyanceId> {

    List<HistoriqueSinistrePrevoyance> findByNosinOrderByDebutDesc(String nosin);

    /*
     * L'etat a une date donnee. Limite a une ligne par un LIMIT applicatif : deux
     * changements d'etat exactement au meme instant sont impossibles, DEBUT
     * faisant partie de la cle.
     */
    @Query("""
           select h
           from HistoriqueSinistrePrevoyance h
             left join fetch h.saisiPar
           where h.nosin = :nosin
             and h.debut <= :date
           order by h.debut desc
           """)
    List<HistoriqueSinistrePrevoyance> findAvantDate(@Param("nosin") String nosin,
                                                     @Param("date") LocalDateTime date);

    Optional<HistoriqueSinistrePrevoyance> findFirstByNosinAndEtatOrderByDebutAsc(
            String nosin, EtatSinistrePrevoyanceEnum etat);

    @Query("""
           select h
           from HistoriqueSinistrePrevoyance h
           where h.nosin in :nosins
           order by h.nosin, h.debut desc
           """)
    List<HistoriqueSinistrePrevoyance> findParNosins(@Param("nosins") Collection<String> nosins);
}
