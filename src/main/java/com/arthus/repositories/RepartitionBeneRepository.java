package com.arthus.repositories;

import com.arthus.entitys.RepartitionBene;
import com.arthus.entitys.RepartitionBene.RepartitionBeneId;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.lang.Long;

/*
 * Repository de REPARTITION_BENE : les beneficiaires d'un sinistre avec leur
 * quote-part.
 *
 * Le double filtre VALIDE = 'O' sur REPARTITION et REPARTITION_BENE est celui de
 * V_REPARTITION_BENE, V_CORRES_MAIL et V_BENE_JUSTIF_SIN. Il est porte par les
 * requetes, jamais par l'appelant.
 */
public interface RepartitionBeneRepository extends JpaRepository<RepartitionBene, RepartitionBeneId> {

    @Query("""
           SELECT rb
           FROM RepartitionBene rb
             JOIN FETCH rb.beneficiaire
             LEFT JOIN FETCH rb.destinataire
             JOIN rb.repartition r
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.valide  = 'O'
             AND rb.valide = 'O'
           ORDER BY rb.idrepartition, rb.numbene
           """)
    List<RepartitionBene> findParNosin(@Param("nosin") String nosin);

    // Restreint a une garantie : une repartition = une garantie
    @Query("""
           SELECT rb
           FROM RepartitionBene rb
             JOIN FETCH rb.beneficiaire
             JOIN rb.repartition r
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.numfor  = :numfor
             AND r.valide  = 'O'
             AND rb.valide = 'O'
           """)
    List<RepartitionBene> findParNosinEtGarantie(@Param("nosin") String nosin,
                                                 @Param("numfor") Long numfor);

    // Version par lot, NOSIN en 1re colonne pour le regroupement cote service
    @Query("""
           SELECT r.sinistrePrevoyance.nosin, rb
           FROM RepartitionBene rb
             JOIN FETCH rb.beneficiaire
             JOIN rb.repartition r
           WHERE r.sinistrePrevoyance.nosin in :nosins
             AND r.valide  = 'O'
             AND rb.valide = 'O'
           ORDER BY r.sinistrePrevoyance.nosin, rb.idrepartition, rb.numbene
           """)
    List<Object[]> findParNosins(@Param("nosins") Collection<String> nosins);
}
