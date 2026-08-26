package com.arthus.repositories;

import com.arthus.entitys.ContratRef;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

/*
 * Repository de CONTRAT_REF. Il porte le souscripteur (NUMCLI) et l'assureur
 * (NUMORG -> PERS_ORGANISME, ROLE = 2).
 *
 * Le contrat d'un sinistre se reJOINt via REPARTITION -> ADHE_CNTRT -> NUMGAR.
 * Toutes les repartitions valides d'un sinistre pointant la meme adhesion, la
 * requete rend au plus une ligne - le distinct sert a le garantir.
 */
public interface ContratRefRepository extends JpaRepository<ContratRef, Long> {

    @Query("""
           SELECT DISTINCT c
           FROM Repartition r
             JOIN r.adhesionContrat a
             JOIN a.contratRef c
             LEFT JOIN FETCH c.souscripteur
             LEFT JOIN FETCH c.organismeAssureur org
             LEFT JOIN FETCH org.individu
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.valide = 'O'
           """)
    List<ContratRef> findParNosin(@Param("nosin") String nosin);

    @Query("""
           SELECT c
           FROM ContratRef c
             LEFT JOIN FETCH c.souscripteur
             LEFT JOIN FETCH c.organismeAssureur org
             LEFT JOIN FETCH org.individu
           WHERE c.numgar = :numgar
           """)
    Optional<ContratRef> findAvecParties(@Param("numgar") Long numgar);
}
