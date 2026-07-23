package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.SupervisoryAuthorityType;

@Repository
public interface SupervisoryAuthorityTypeRepository extends JpaRepository<SupervisoryAuthorityType, Integer> {
	
    @Cacheable(cacheNames = "supervisory_authority_type")
    List<SupervisoryAuthorityType> findAll();

    Optional<SupervisoryAuthorityType> findByIntlId(String intlId);

}
