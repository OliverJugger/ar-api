package com.arthus.repositories;

import java.util.Optional;
import com.arthus.entitys.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Page;
import org.springframework.data.repository.query.Param;
 
import java.util.List;

public interface UtilisateurRepository extends JpaRepository<Utilisateur, String> {
	Optional<Utilisateur> findByNomIgnoreCase(String nom);
}
 