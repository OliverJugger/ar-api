package com.arthus.repositories;

import com.arthus.entitys.Beneficiaire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

/*
 * Repository de BENEFICIAIRE - le referentiel des beneficiaires declares, a ne
 * pas confondre avec REPARTITION_BENE qui porte les quotes-parts d'un sinistre.
 * Son seul apport reel est TYPE_BENE.
 *
 * BENEFICIAIRE n'a ni PK ni FK en base : la jointure vers la repartition se fait
 * sur (IDADHESION, NUMFOR), comme dans PK_PRDG_FONCT, et NUMINDIV y designe
 * l'assure (NUMBENE etant le beneficiaire).
 *
 * L'entite ayant une cle composite de quatre colonnes, l'id du JpaRepository est
 * la classe Beneficiaire.BeneficiaireId.
 */
public interface BeneficiaireRepository extends JpaRepository<Beneficiaire, Beneficiaire.BeneficiaireId> {

    List<Beneficiaire> findByIdadhesionAndNumfor(Long idadhesion, Long numfor);

    @Query("""
           SELECT b
           FROM Beneficiaire b, Repartition r
           WHERE r.sinistrePrevoyance.nosin = :nosin
             AND r.valide = 'O'
             AND b.idadhesion = r.adhesionContrat.idadhesion
             AND b.numfor     = r.numfor
             AND b.numindiv   = :numindivAssure
           """)
    List<Beneficiaire> findDeclaresParNosin(@Param("nosin") String nosin, @Param("numindivAssure") Long numindivAssure);
}
