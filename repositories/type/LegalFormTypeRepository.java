package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.LegalFormType;

@Repository
public interface LegalFormTypeRepository extends JpaRepository<LegalFormType, Integer> {
	
	@Cacheable(cacheNames = "legal_form_type")
	List<LegalFormType> findAll();

	Optional<LegalFormType> findByIntlId(String intlId);
}
