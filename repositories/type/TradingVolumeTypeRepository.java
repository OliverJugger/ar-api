package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.TradingVolumeType;

@Repository
public interface TradingVolumeTypeRepository extends JpaRepository<TradingVolumeType, Integer> {
	
    @Cacheable(cacheNames = "trading_volume_cache")
    List<TradingVolumeType> findAll();

}
