package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.DedicatedSubFundType;

@Repository
public interface DedicatedSubFundTypeRepository extends JpaRepository<DedicatedSubFundType, Integer> {
	
    @Cacheable(cacheNames = "dedicated_sub_fund_type")
    List<DedicatedSubFundType> findAll();
    
    Optional<DedicatedSubFundType> findByIntlId(String intlId);
}
