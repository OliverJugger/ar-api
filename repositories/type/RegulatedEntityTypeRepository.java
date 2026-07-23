package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.RegulatedEntityType;

@Repository
public interface RegulatedEntityTypeRepository extends JpaRepository<RegulatedEntityType, Integer> {
	
    @Cacheable(cacheNames = "regulated_entity_type")
    List<RegulatedEntityType> findAll();

    Optional<RegulatedEntityType> findByIntlId(String intlId);
}
