package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.TermType;

@Repository
public interface TermTypeRepository extends JpaRepository<TermType, Integer> {
	
    @Cacheable(cacheNames = "term_type")
    List<TermType> findAll();
    
    Optional<TermType> findByIntlId(String intlId);
}
