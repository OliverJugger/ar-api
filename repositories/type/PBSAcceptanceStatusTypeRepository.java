package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.PBSAcceptanceStatusType;

@Repository
public interface PBSAcceptanceStatusTypeRepository extends JpaRepository<PBSAcceptanceStatusType, Integer> {

    @Cacheable(cacheNames = "pbs_cache")
    List<PBSAcceptanceStatusType> findAll();
}
