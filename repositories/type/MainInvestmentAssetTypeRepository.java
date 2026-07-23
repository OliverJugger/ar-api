package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.MainInvestmentAssetType;

@Repository
public interface MainInvestmentAssetTypeRepository extends JpaRepository<MainInvestmentAssetType, Integer> {
	
	@Cacheable(cacheNames = "main_investment_asset_type")
	List<MainInvestmentAssetType> findAll();
	
	Optional<MainInvestmentAssetType> findByIntlId(String intlId);
}
