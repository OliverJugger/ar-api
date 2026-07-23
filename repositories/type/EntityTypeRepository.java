package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.bdl.epbs_fund_api.model.types.EPBSEntityType;

public interface EntityTypeRepository extends JpaRepository<EPBSEntityType, Integer> {
	
    @Cacheable(cacheNames = "epbs_entity_type")
    List<EPBSEntityType> findAll();

	@Query("Select entityType from EPBSEntityType entityType where intlId = :intlId ")
	EPBSEntityType findByIntlId(@Param("intlId") String intlId);
}
