package com.arthus.repositories.specification.rules.dossier_sinistre;

import java.util.Optional;

import org.springframework.stereotype.Component;

import com.arthus.entitys.AdhesionContrat;
import com.arthus.entitys.DossierSinistre;
import com.arthus.entitys.Repartition;
import com.arthus.entitys.SinistrePrevoyance;
import com.arthus.repositories.specification.criteria.DossierSinistreSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;

@Component
public class DossierSinistreNumeroContratRule implements DossierSinistreRule {

    private static final long serialVersionUID = 1L;

    @Override
    public boolean matches(DossierSinistreSearchCriteria criteria) {
        return Optional.ofNullable(criteria)
                .map(DossierSinistreSearchCriteria::getNumeroContrat)
                .isPresent();
    }

    @Override
    public Predicate apply(Root<DossierSinistre> root, CriteriaQuery<?> query, CriteriaBuilder builder, DossierSinistreSearchCriteria criteria) {
        Subquery<Integer> sub = query.subquery(Integer.class);
        Root<Repartition> repartition = sub.from(Repartition.class);

        Join<Repartition, SinistrePrevoyance> sinistre = repartition.join("sinistrePrevoyance");
        Join<Repartition, AdhesionContrat> adhesion = repartition.join("adhesionContrat");

        sub.select(builder.literal(1))
           .where(
                builder.equal(sinistre.get("dossierSinistre"), root),
                builder.equal(adhesion.get("numgar"), criteria.getNumeroContrat()),
                builder.equal(repartition.get("valide"), "O")
           );

        return builder.exists(sub);
    }
}