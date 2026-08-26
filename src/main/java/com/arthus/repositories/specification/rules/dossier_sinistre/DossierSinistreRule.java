package com.arthus.repositories.specification.rules.dossier_sinistre;

import java.io.Serializable;

import com.arthus.entitys.DossierSinistre;
import com.arthus.repositories.specification.criteria.DossierSinistreSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public interface DossierSinistreRule extends Serializable {
    boolean matches(DossierSinistreSearchCriteria criteria);
    Predicate apply(Root<DossierSinistre> root, CriteriaQuery<?> query, CriteriaBuilder builder, DossierSinistreSearchCriteria criteria);
}