package com.arthus.repositories.contextuel;

import com.arthus.entitys.contextuel.Rappel;
import com.arthus.entitys.enums.ContexteEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

/*
 * Chargement brut des rappels par (contexte, entites). Filtres et regroupements
 * dans RappelService.
 *
 * Rappel : IDRAPPEL sert de @Id sans etre unique en base. Si un doublon existe,
 * c'est ici qu'il se manifestera - deux lignes fusionnees en une par le cache de
 * premier niveau d'Hibernate.
 */
public interface RappelRepository extends JpaRepository<Rappel, Long> {

    @Query("""
           select r
           from Rappel r
             left join fetch r.assure
             left join fetch r.beneficiaire
           where r.contexte = :contexte
             and r.entite in :entites
           order by r.entite, r.dateeffet desc, r.idrappel desc
           """)
    List<Rappel> findByContexteEtEntites(@Param("contexte") ContexteEnum contexte,
                                         @Param("entites") Collection<Long> entites);
}
