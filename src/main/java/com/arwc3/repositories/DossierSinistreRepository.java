package com.arwc3.repositories;

import com.arwc3.entitys.DossierSinistre;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DossierSinistreRepository extends JpaRepository<DossierSinistre, String> {
    List<DossierSinistre> findAllByNumIndiv(Long numIndiv);
}
