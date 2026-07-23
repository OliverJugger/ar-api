package com.arwc3.repositories.specification.rules.dossier_sinistre;

import java.util.Objects;
import java.util.Optional;

import org.apache.commons.lang3.BooleanUtils;
import org.springframework.stereotype.Component;

import com.arwc3.entitys.DossierSinistre;
import com.arwc3.repositories.specification.criteria.DossierSinistreSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class DossierSinistreAnterieurRule implements DossierSinistreRule {
	
	private static final long serialVersionUID = 1L;
	
	@Override
    public boolean matches(DossierSinistreSearchCriteria criteria) {
    	return Optional.ofNullable(criteria)
    			.map(DossierSinistreSearchCriteria::getAnterieur)
    			.map(Objects::nonNull)
    			.orElse(false);
    }

    @Override
    public Predicate apply(Root<DossierSinistre> root, CriteriaBuilder builder, DossierSinistreSearchCriteria criteria) {
		return builder.equal(root.get("anterieur"), BooleanUtils.isTrue(criteria.getAnterieur()) ? "O" : "N");
    }
}