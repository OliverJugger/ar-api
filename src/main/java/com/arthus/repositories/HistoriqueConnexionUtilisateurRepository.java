package com.arthus.repositories;

import com.arthus.entitys.HistoriqueConnexionUtilisateur;
import com.arthus.entitys.HistoriqueConnexionUtilisateurId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Page;
import org.springframework.data.repository.query.Param;
 
import java.util.List;

public interface HistoriqueConnexionUtilisateurRepository extends JpaRepository<HistoriqueConnexionUtilisateur, HistoriqueConnexionUtilisateurId> {
}
 