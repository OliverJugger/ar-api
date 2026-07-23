package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.ClientSegmentationType;

@Repository
public interface ClientSegmentationTypeRepository extends JpaRepository<ClientSegmentationType, Integer> {
	
    @Cacheable(cacheNames = "client_segmentation_type")
    List<ClientSegmentationType> findAll();

    Optional<ClientSegmentationType> findByIntlId (String intlId);
}
