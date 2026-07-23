package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.DistributionStrategyType;

@Repository
public interface DistributionStrategyTypeRepository extends JpaRepository<DistributionStrategyType, Integer> {

    @Cacheable(cacheNames = "distribution_strategy_type")
    List<DistributionStrategyType> findAll();

}
