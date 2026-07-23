package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;

import com.bdl.epbs_fund_api.model.types.UnderlyingClientResidenceCountryType;

public interface UnderlyingClientResidenceCountryTypeRepository extends JpaRepository<UnderlyingClientResidenceCountryType, Integer> {
	
    @Cacheable(cacheNames = "underlying_client_residence_country_cache")
    List<UnderlyingClientResidenceCountryType> findAll();

}
