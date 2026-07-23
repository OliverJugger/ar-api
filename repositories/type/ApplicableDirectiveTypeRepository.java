package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.ApplicableDirectiveType;

@Repository
public interface ApplicableDirectiveTypeRepository extends JpaRepository<ApplicableDirectiveType, Integer> {
	
    @Cacheable(cacheNames = "applicable_directive_type")
    List<ApplicableDirectiveType> findAll();

    Optional<ApplicableDirectiveType> findByIntlId(String intlId);

}
