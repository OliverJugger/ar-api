package com.arthus.repositories.contextuel;

import com.arthus.entitys.contextuel.Correspondant;
import com.arthus.entitys.enums.ContexteEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

/*
 * Volontairement mince : pas de conversion de NOSIN, pas de filtrage metier,
 * pas de methode "par defaut". Tout ca est dans CorrespondantService.
 * Ici on ne fait que charger par (contexte, entites), en une seule requete.
 *
 * Le contexte est passe en parametre plutot qu'ecrit en dur : la colonne passant
 * par un AttributeConverter, Hibernate convertit proprement un parametre lie, la
 * ou un litteral enum dans le texte JPQL est nettement plus capricieux.
 */
public interface CorrespondantRepository extends JpaRepository<Correspondant, Long> {

    @Query("""
           select c
           from Correspondant c
             left join fetch c.correspondant
             left join fetch c.interlocuteur
           where c.contexte = :contexte
             and c.entite in :entites
           order by c.entite, c.natCorres, c.idCorres
           """)
    List<Correspondant> findByContexteEtEntites(@Param("contexte") ContexteEnum contexte,
                                                @Param("entites") Collection<Long> entites);
}
