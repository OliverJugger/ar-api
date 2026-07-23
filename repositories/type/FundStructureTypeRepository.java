package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.FundStructureType;

@Repository
public interface FundStructureTypeRepository  extends JpaRepository<FundStructureType, Integer>{

    @Cacheable(cacheNames = "fund_structure_cache")
    List<FundStructureType> findAll();
    
	FundStructureType findByIntlId(String intlId);
}

