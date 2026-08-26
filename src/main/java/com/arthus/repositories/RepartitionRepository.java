package com.arthus.repositories;

import com.arthus.entitys.Repartition;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

/*
 * Repository de REPARTITION, le pivot entre le sinistre, l'adhesion et la
 * garantie. Il ne ramene que des Repartition : les requetes qui ramenent des
 * garanties ou des beneficiaires sont chez eux.
 *
 * Le filtre VALIDE = 'O' n'est pas negociable : c'est ce que fait
 * f_idadhesion_prev, et toutes les vues legacy.
 */
public interface RepartitionRepository extends JpaRepository<Repartition, Long> {

    @Query("""
           SELECT r
           FROM Repartition r
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.valide = 'O'
           """)
    List<Repartition> findValidesParNosin(@Param("nosin") String nosin);

    /*
     * Repartitions valides avec garantie ET beneficiaires charges en une passe.
     * C'est la requete a utiliser quAND un ecran affiche les deux : sans le JOIN
     * FETCH, chaque acces a r.getGarantie() coute un SELECT.
     *
     * Le JOIN FETCH sur la collection interdit la pagination JPA (Hibernate
     * paginerait en memoire) : on passe une liste de NOSIN deja bornee par
     * l'appelant, jamais un Pageable.
     */
    @Query("""
           SELECT DISTINCT r
           FROM Repartition r
             JOIN FETCH r.garantie g
             LEFT JOIN FETCH r.beneficiaires rb
             LEFT JOIN FETCH rb.beneficiaire
           WHERE r.sinistrePrevoyance.nosin in :nosins
             AND r.valide = 'O'
             AND g.valide = 'O'
           """)
    List<Repartition> findValidesAvecGarantieEtBeneficiaires(@Param("nosins") Collection<String> nosins);

    /*
     * L'IDADHESION du sinistre. Toutes les repartitions valides d'un sinistre
     * portent le meme, c'est l'hypothese de f_idadhesion_prev qui en prend une au
     * hasard. Le DISTINCT permet de verifier que l'hypothese tient.
     */
    @Query("""
           SELECT DISTINCT r.adhesionContrat.idadhesion
           FROM Repartition r
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.valide = 'O'
           """)
    List<Long> findIdAdhesionsParNosin(@Param("nosin") String nosin);
}
