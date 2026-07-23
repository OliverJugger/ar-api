package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.InvestmentStrategyType;

@Repository
public interface InvestmentStrategyTypeRepository extends JpaRepository<InvestmentStrategyType, Integer> {
	
	@Cacheable(cacheNames = "investment_strategy_type")
	List<InvestmentStrategyType> findAll();
	
	Optional<InvestmentStrategyType> findByIntlId(String intlId);
}
