package com.arthus.repositories;

import com.arthus.entitys.GarantieContratRef;
import com.arthus.repositories.lecture.GarantieSinistreView;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

/*
 * Repository de GAR_CNTRT_REF. Les requetes partent de REPARTITION mais ramenent
 * des garanties : c'est ce qui les place ici et non dans RepartitionRepository.
 */
public interface GarantieContratRefRepository extends JpaRepository<GarantieContratRef, Long> {

    List<GarantieContratRef> findByNumgarAndValideOrderByNumfor(Long numgar, String valide);
	
	// Les garanties valides d'un sinistre, dedoublonnees
    @Query("""
           SELECT DISTINCT g
           FROM Repartition r
             JOIN r.garantie g
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.valide = 'O'
             AND g.valide = 'O'
           ORDER BY g.numfor
           """)
    List<GarantieContratRef> findByNosin(@Param("nosin") String nosin);

    /*
     * Garanties enrichies des dates de couverture (ADHESION.DATAPLI / DATPER).
     * Transposition fidele de la requete Forms, generalisee au sinistre entier :
     * l'originale etait bindee sur :repartition.numfor / :repartition.idadhesion.
     *
     * Le 2e terme de l'UNION couvre l'adhesion a un GROUPE de garanties
     * (ADHESION.NUMFOR = GRP_GAR_DEF.NUMGRPGAR, cas PREV CARCO) et exige alors
     * a.numindiv = :numindiv - le :tronc.numindiv de l'ecran, soit l'assure.
     *
     * Reste en natif : JPQL ne connait ni UNION ni max() sur cette forme de
     * jointure. Les vues legacy GAR_CNTRT et CONTRAT sont remplacees par leurs
     * tables GAR_CNTRT_REF et CONTRAT_REF - les branches "adhesion collective"
     * sont donc absentes, voir le README.
     */
    @Query(value = """
           SELECT g.numfor        AS numfor,
                  g.nomgar        AS nomgar,
                  g.libelle       AS libelle,
                  r.valide        AS valide,
                  c.numgar        AS numgar,
                  c.refcie        AS refcie,
                  MAX(a.datapli)  AS datesous,
                  MAX(a.datper)   AS datper
           FROM   arthus.repartition   r
                  JOIN arthus.gar_cntrt_ref g ON g.numfor = r.numfor
                  JOIN arthus.contrat_ref   c ON c.numgar = g.numgar
                  JOIN arthus.adhesion      a ON a.numfor = g.numfor
                                             AND a.idadhesion = r.idadhesion
           WHERE  r.nosin  = :nosin
           AND    r.valide = 'O'
           AND    g.valide = 'O'
           GROUP BY g.numfor, g.nomgar, g.libelle, r.valide, c.numgar, c.refcie
           UNION
           SELECT g.numfor, g.nomgar, g.libelle, r.valide, c.numgar, c.refcie,
                  MAX(a.datapli), MAX(a.datper)
           FROM   arthus.repartition   r
                  JOIN arthus.gar_cntrt_ref g   ON g.numfor = r.numfor
                  JOIN arthus.contrat_ref   c   ON c.numgar = g.numgar
                  JOIN arthus.grp_gar_def   grp ON grp.numfor = g.numfor
                  JOIN arthus.adhesion      a   ON a.numfor = grp.numgrpgar
                                                AND a.idadhesion = r.idadhesion
                                                AND a.numindiv   = :numindiv
           WHERE  r.nosin  = :nosin
           AND    r.valide = 'O'
           AND    g.valide = 'O'
           GROUP BY g.numfor, g.nomgar, g.libelle, r.valide, c.numgar, c.refcie
           """, nativeQuery = true)
    List<GarantieSinistreView> findAvecDatesParNosin(@Param("nosin") String nosin, @Param("numindiv") Long numindiv);
}
