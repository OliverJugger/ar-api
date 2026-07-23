package com.arwc3.repositories.specification.rules.dossier_sinistre;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.arwc3.entitys.DossierSinistre;
import com.arwc3.entitys.Individu;
import com.arwc3.repositories.specification.criteria.DossierSinistreSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Join;

@Component
public class DossierSinistreNomIndividuContainsRule implements DossierSinistreRule {
	
	private static final long serialVersionUID = 1L;
	
	@Override
	public boolean matches(DossierSinistreSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(DossierSinistreSearchCriteria::getNomIndividuContains)
				.map(Objects::nonNull)
				.orElse(false);
	}

    @Override
    public Predicate apply(Root<DossierSinistre> root, CriteriaBuilder builder, DossierSinistreSearchCriteria criteria) {

		Join<Individu, DossierSinistre> individu = root
				.join("individu");

		return builder.like(
					builder.lower(individu.get("nom")),
					'%' + criteria.getNomIndividuContains().toLowerCase() + '%');
    }
}