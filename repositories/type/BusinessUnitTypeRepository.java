package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.BusinessUnitType;

@Repository
public interface BusinessUnitTypeRepository extends JpaRepository<BusinessUnitType, Integer> {
    
	@Cacheable(cacheNames = "business_unit_cache")
	List<BusinessUnitType> findAll();

	Optional<BusinessUnitType> findByIntlId(String intlId);
}