package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.UCIEntityType;

@Repository
public interface UCIEntityTypeRepository extends JpaRepository<UCIEntityType, Integer> {
	
    @Cacheable(cacheNames = "uci_entity_type")
    List<UCIEntityType> findAll();

    UCIEntityType findByIntlId(String intlId);

}
