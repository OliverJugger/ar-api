package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.RegulatedAsType;

@Repository
public interface RegulatedAsTypeRepository extends JpaRepository<RegulatedAsType, Integer> {
	
    @Cacheable(cacheNames = "regulated_as_type")
    List<RegulatedAsType> findAll();

    Optional<RegulatedAsType> findByIntlId(String intlId);

}
