package com.arwc3.repositories;

import com.arwc3.entitys.DossierSinistre;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface DossierSinistreRepository extends JpaRepository<DossierSinistre, String>, JpaSpecificationExecutor<DossierSinistre> {
}
