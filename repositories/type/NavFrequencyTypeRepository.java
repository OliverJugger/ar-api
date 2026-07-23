package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.NavFrequencyType;

@Repository
public interface NavFrequencyTypeRepository extends JpaRepository<NavFrequencyType, Integer> {
	
	@Cacheable(cacheNames = "nav_frequency_type")
	List<NavFrequencyType> findAll();
	
	Optional<NavFrequencyType> findByIntlId(String intlId);
}
