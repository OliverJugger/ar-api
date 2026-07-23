package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.SRABStatusType;

@Repository
public interface SRABStatusRepository extends JpaRepository<SRABStatusType, Integer> {
	
    @Cacheable(cacheNames = "srab_status_type")
    List<SRABStatusType> findAll();

    Optional<SRABStatusType> findByIntlId(String intlId);
}
