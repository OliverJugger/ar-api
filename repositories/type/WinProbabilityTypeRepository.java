package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.WinProbabilityType;

@Repository
public interface WinProbabilityTypeRepository extends JpaRepository<WinProbabilityType, Integer> {
	
	 @Cacheable(cacheNames = "win_probability_cache")
	    List<WinProbabilityType> findAll();


}
