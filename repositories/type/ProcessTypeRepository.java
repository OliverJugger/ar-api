package com.bdl.epbs_fund_api.repositories.type;

import com.bdl.epbs_fund_api.model.types.ProcessType;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProcessTypeRepository extends JpaRepository<ProcessType, Integer> {

    @Cacheable(cacheNames = "process_type")
    List<ProcessType> findAll();

    Optional<ProcessType> findByIntlId(String intlId);
}
