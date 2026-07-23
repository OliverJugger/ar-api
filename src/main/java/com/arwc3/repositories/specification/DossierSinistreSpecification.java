package com.arwc3.repositories.specification;

import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.arwc3.entitys.DossierSinistre;
import com.arwc3.repositories.specification.criteria.DossierSinistreSearchCriteria;
import com.arwc3.repositories.specification.rules.dossier_sinistre.DossierSinistreRule;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;

import jakarta.persistence.criteria.Predicate;

public class DossierSinistreSpecification implements Specification<DossierSinistre>{
	
	private static final long serialVersionUID = 1L;

	private final DossierSinistreSearchCriteria criteria;
    private final List<DossierSinistreRule> predicatesAnd;

    public DossierSinistreSpecification(final DossierSinistreSearchCriteria searchCriteria, final List<DossierSinistreRule> predicatesAnd) {
        super();
        this.criteria = searchCriteria;
        this.predicatesAnd = predicatesAnd;
    }

    @Override
    public Predicate toPredicate(Root<DossierSinistre> root, CriteriaQuery<?> query, CriteriaBuilder builder) {
        List<Predicate> predicatesMatch = predicatesAnd.stream()
                .filter(rule -> rule.matches(criteria))
                .map(rule -> rule.apply(root, builder, criteria))
                .toList();
        return builder.and(predicatesMatch.toArray(new Predicate[0]));
    }

}
