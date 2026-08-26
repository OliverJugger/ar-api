package com.arthus.repositories;

import com.arthus.repositories.lecture.GarantieSinistreView;
import com.arthus.entitys.GarantieContratRef;
import com.arthus.entitys.RepartitionBene;
import com.arthus.entitys.Repartition;
import com.arthus.entitys.Beneficiaire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

/*
 * Requêtes de lecture autour d'un sinistre prévoyance (NOSIN) :
 * ses garanties et ses bénéficiaires.
 *
 * Le repository est monté sur Repartition parce que c'est le pivot des
 * deux liens
 */
public interface SinistreGarantieRepository extends JpaRepository<Repartition, Long> {

    /* ================================================================== */
    /* 1. Garanties du sinistre — version JPQL simple                     */
    /* ================================================================== */

    /*
     * Les garanties valides rattachées à un sinistre.
     * Suffit dès qu'on n'a pas besoin des dates de couverture (DATAPLI/DATPER
     * d'ADHESION) : celles-ci demANDent la requête native ci-dessous.
     */
    @Query("""
           SELECT DISTINCT g
           FROM Repartition r
             JOIN r.garantie g
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.valide = 'O'
             AND g.valide = 'O'
           ORDER BY g.numfor
           """)
    List<GarantieContratRef> findGarantiesByNosin(@Param("nosin") String nosin);

    /* ================================================================== */
    /* 2. Garanties + dates de couverture — transposition de la requête    */
    /*    Forms (UNION avec le cas « groupe de garanties » PREV CARCO)     */
    /* ================================================================== */

    /*
     * Transposition fidèle de l'ancienne requête, généralisée au sinistre entier :
     * l'original était bindé sur une répartition courante
     * (repartition.numfor / repartition.idadhesion), ici on part
     * du NOSIN et on parcourt toutes ses répartitions valides.
     *
     * Le 2ᵉ terme de l'UNION couvre le cas où l'individu a adhéré à un
     * groupe de garanties (ADHESION.NUMFOR = GRP_GAR_DEF.NUMGRPGAR) et non à
     * la garantie unitaire ; il exige alors a.numindiv = :numindiv
     * (le tronc.numindiv de Forms = l'assuré du dossier).
     *
     * Reste en natif : JPQL ne connaît ni UNION ni max() sur une JOINture
     * de ce type. Les vues legacy GAR_CNTRT et CONTRAT sont remplacées ici par leurs
     * tables : GAR_CNTRT_REF et CONTRAT_REF (voir README pour les deux branches
     * « adhésion collective » à rajouter en UNION si tes clients les utilisent).
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
           FROM   arthus.repartition r
                  JOIN arthus.gar_cntrt_ref g ON g.numfor = r.numfor
                  JOIN arthus.contrat_ref   c ON c.numgar = g.numgar
                  JOIN arthus.adhesion  a ON a.numfor = g.numfor
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
                  JOIN arthus.grp_gar_def  grp ON grp.numfor = g.numfor
                  JOIN arthus.adhesion     a   ON a.numfor = grp.numgrpgar
                                              AND a.idadhesion = r.idadhesion
                                              AND a.numindiv   = :numindiv
           WHERE  r.nosin  = :nosin
           AND    r.valide = 'O'
           AND    g.valide = 'O'
           GROUP BY g.numfor, g.nomgar, g.libelle, r.valide, c.numgar, c.refcie
           """, nativeQuery = true)
    List<GarantieSinistreView> findGarantiesAvecDates(@Param("nosin") String nosin, @Param("numindiv") Long numindiv);

    /* ================================================================== */
    /* 3. Bénéficiaires du sinistre                                        */
    /* ================================================================== */

    /*
     * Les bénéficiaires d'un sinistre, avec leur quote-part, la personne et le
     * destinataire du règlement chargés d'un coup.
     * Double filtre VALIDE='O' sur REPARTITION et REPARTITION_BENE :
     * c'est exactement ce que font V_REPARTITION_BENE et V_CORRES_MAIL.
     */
    @Query("""
           SELECT rb
           FROM RepartitionBene rb
             JOIN FETCH rb.beneficiaire
             left JOIN FETCH rb.destinataire
             JOIN rb.repartition r
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.valide  = 'O'
             AND rb.valide = 'O'
           ORDER BY rb.idrepartition, rb.numbene
           """)
    List<RepartitionBene> findBeneficiairesByNosin(@Param("nosin") String nosin);

    /*
     * Idem, restreint à une garantie donnée (une répartition = une garantie).
     */
    @Query("""
           SELECT rb
           FROM RepartitionBene rb
             JOIN FETCH rb.beneficiaire
             JOIN rb.repartition r
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.numfor = :numfor
             AND r.valide  = 'O'
             AND rb.valide = 'O'
           """)
    List<RepartitionBene> findBeneficiairesByNosinEtGarantie(@Param("nosin") String nosin, @Param("numfor") Long numfor);

    /*
     * Le TYPE_BENE déclaré (mnémo LIBELLE 'TYPE_BENE') pour les bénéficiaires du
     * sinistre : BENEFICIAIRE n'a pas de FK vers REPARTITION, la JOINture se fait
     * sur (IDADHESION, NUMFOR) — cf. PK_PRDG_FONCT.
     */
    @Query("""
           SELECT b
           FROM com.arthus.entitys.Beneficiaire b, Repartition r
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.valide = 'O'
             AND b.idadhesion = r.adhesionContrat.idadhesion
             AND b.numfor     = r.numfor
             AND b.numindiv   = :numindivAssure
           """)
    List<Beneficiaire> findBeneficiairesDeclares(@Param("nosin") String nosin, @Param("numindivAssure") Long numindivAssure);

    /* ================================================================== */
    /* 4. Chargement par lot - a utiliser des qu'on affiche une liste      */
    /* ================================================================== */

    /*
     * Les repartitions valides de plusieurs sinistres, garantie et beneficiaires
     * charges en meme temps. Une requete pour toute une page.
     *
     * Le JOIN FETCH sur la collection empeche la pagination JPA (Hibernate
     * paginerait en memoire) : on passe donc une liste de NOSIN deja bornee par
     * l'appelant, jamais une Pageable.
     */
    @Query("""
           SELECT DISTINCT r
           FROM Repartition r
             JOIN FETCH r.garantie g
             left JOIN FETCH r.beneficiaires rb
             left JOIN FETCH rb.beneficiaire
           WHERE r.sinistrePrevoyance.nosin in :nosins
             AND r.valide = 'O'
             AND g.valide = 'O'
           """)
    List<Repartition> findRepartitionsValidesAvecGarantie(@Param("nosins") Collection<String> nosins);

}
