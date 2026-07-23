package com.bdl.epbs_fund_api.repositories.type;

import com.bdl.epbs_fund_api.model.types.ConvAMAcceptanceStatusType;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConvAMAcceptanceStatusTypeRepository extends JpaRepository<ConvAMAcceptanceStatusType, Integer> {

    @Cacheable(cacheNames = "convam_cache")
    List<ConvAMAcceptanceStatusType> findAll();
}
