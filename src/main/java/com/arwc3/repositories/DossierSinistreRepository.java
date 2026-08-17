package com.arwc3.repositories;

import com.arwc3.entitys.DossierSinistre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
 
import java.util.List;

/**
 * Remplace la vue ARTHUS.V_DOSSIER_SIN_CONTRAT + la fonction f_idadhesion_prev.
 *
 * Chaîne parcourue :
 *   CONTRAT_REF (NUMGAR)
 *     ← ADHE_CNTRT (NUMGAR / IDADHESION)
 *     ← REPARTITION (IDADHESION / NOSIN, VALIDE='O')   <-- ex f_idadhesion_prev
 *     → SNTR_PREV (NOSIN / IDDOSSIER)
 *     → DOSSIER_SINISTRE (IDDOSSIER)
 *
 * PK de DOSSIER_SINISTRE = IDDOSSIER (String) → JpaRepository<..., String>.
 */
public interface DossierSinistreRepository extends JpaRepository<DossierSinistre, String>, JpaSpecificationExecutor<DossierSinistre> {
	/**
     * Retourne les dossiers sinistre rattachés à un contrat (NUMGAR).
     * On part de REPARTITION pour appliquer directement le filtre VALIDE='O',
     * puis on remonte au dossier. Le DISTINCT reproduit celui de la vue.
     */
    @Query("""
           select distinct r.sntrPrev.dossierSinistre
           from Repartition r
           where r.adheCntrt.numgar = :numgar
             and r.valide = 'O'
           """)
    List<DossierSinistre> findByNumgar(@Param("numgar") Long numgar);
}
  