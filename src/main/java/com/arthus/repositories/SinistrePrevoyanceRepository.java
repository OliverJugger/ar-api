package com.arthus.repositories;

import com.arthus.entitys.SinistrePrevoyance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

/*
 * Repository de SNTR_PREV. Une regle tenue dans tout ce package : un repository
 * ne retourne que son entite (ou une projection de celle-ci). Les traversees qui
 * ramenent AUTRE CHOSE vivent dans le repository de l'entite retournee, et les
 * projections transverses dans com.arthus.repositories.lecture.
 */
public interface SinistrePrevoyanceRepository extends JpaRepository<SinistrePrevoyance, String> {

    @Query("""
           select s
           from SinistrePrevoyance s
             join fetch s.dossierSinistre d
             left join fetch d.assure
           where s.nosin = :nosin
           """)
    Optional<SinistrePrevoyance> findAvecDossier(@Param("nosin") String nosin);

    // Les sinistres d'un dossier, du plus recent au plus ancien
    List<SinistrePrevoyance> findByDossierSinistreIdDossierOrderBySurvenanceDesc(String idDossier);

    @Query("""
           select s
           from SinistrePrevoyance s
             join fetch s.dossierSinistre d
             left join fetch d.assure
           where s.nosin in :nosins
           """)
    List<SinistrePrevoyance> findAvecDossier(@Param("nosins") Collection<String> nosins);
}
