package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.InstitutionalSectorType;

@Repository
public interface InstitutionalSectorTypeRepository extends JpaRepository<InstitutionalSectorType, Integer> {
	
	@Cacheable(cacheNames = "institutional_sector_type")
	List<InstitutionalSectorType> findAll();
	
	Optional<InstitutionalSectorType> findByIntlId (String intlId);
}
