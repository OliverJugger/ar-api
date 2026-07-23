package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.InvestmentGeographyType;

@Repository
public interface InvestmentGeographyTypeRepository extends JpaRepository<InvestmentGeographyType, Integer> {
	
	@Cacheable(cacheNames = "investment_geography_type")
	List<InvestmentGeographyType> findAll();
	
    Optional<InvestmentGeographyType> findByIntlId (String intlId);

}
