package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.ApplicableLawType;

@Repository
public interface ApplicableLawTypeRepository extends JpaRepository<ApplicableLawType, Integer> {
	
    @Cacheable(cacheNames = "applicable_law_type")
    List<ApplicableLawType> findAll();

    Optional<ApplicableLawType> findByIntlId(String intlId);
}
