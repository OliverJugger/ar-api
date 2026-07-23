package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.RelatedIndividualType;

@Repository
public interface RelatedIndividualTypeRepository extends JpaRepository<RelatedIndividualType, Integer>, JpaSpecificationExecutor<RelatedIndividualType> {
	
    @Cacheable(cacheNames = "related_individual_type")
    List<RelatedIndividualType> findAll();

    Optional<RelatedIndividualType> findByIntlId(String intlId);
}
