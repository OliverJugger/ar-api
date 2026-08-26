package com.arthus.repositories.specification.rules.dossier_sinistre;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.arthus.entitys.DossierSinistre;
import com.arthus.repositories.specification.criteria.DossierSinistreSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class DossierSinistreFinFromRule implements DossierSinistreRule {
	
	private static final long serialVersionUID = 1L;
	
	@Override
    public boolean matches(DossierSinistreSearchCriteria criteria) {
    	return Optional.ofNullable(criteria)
    			.map(DossierSinistreSearchCriteria::getFinFrom)
    			.map(Objects::nonNull)
    			.orElse(false);
    }

    @Override
    public Predicate apply(Root<DossierSinistre> root, CriteriaQuery<?> query, CriteriaBuilder builder, DossierSinistreSearchCriteria criteria) {
		return builder.greaterThanOrEqualTo(root.get("fin"), criteria.getFinFrom().atStartOfDay());
    }
}