package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.ESGClassificationType;

@Repository
public interface ESGClassificationTypeRepository extends JpaRepository<ESGClassificationType, Integer> {
	
	@Cacheable(cacheNames = "esg_classification_type")
    List<ESGClassificationType> findAll();

	Optional<ESGClassificationType> findByIntlId(String intlId);
}
