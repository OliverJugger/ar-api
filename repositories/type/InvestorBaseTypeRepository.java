package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.InvestorBaseType;

@Repository
public interface InvestorBaseTypeRepository extends JpaRepository<InvestorBaseType, Integer> {

    @Cacheable(cacheNames = "investor_base_cache")
    List<InvestorBaseType> findAll();
    
    Optional<InvestorBaseType> findByIntlId(String intlId);

}
