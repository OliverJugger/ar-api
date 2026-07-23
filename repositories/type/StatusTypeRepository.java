package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.StatusType;

@Repository
public interface StatusTypeRepository extends JpaRepository<StatusType, Integer> {
	
    @Cacheable(cacheNames = "status_type")
    List<StatusType> findAll();
    
	Optional<StatusType> findByIntlId(String intlId);

}
