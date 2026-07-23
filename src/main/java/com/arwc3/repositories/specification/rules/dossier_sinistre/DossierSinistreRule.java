package com.arwc3.repositories.specification.rules.dossier_sinistre;

import java.io.Serializable;

import com.arwc3.entitys.DossierSinistre;
import com.arwc3.repositories.specification.criteria.DossierSinistreSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Predicate;

public interface DossierSinistreRule extends Serializable {
    boolean matches(DossierSinistreSearchCriteria criteria);
    Predicate apply(Root<DossierSinistre> root, CriteriaBuilder builder, DossierSinistreSearchCriteria criteria);
}