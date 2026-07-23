package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.InChargeType;

@Repository
public interface ChargeOfTypeRepository extends JpaRepository<InChargeType, Integer> {

    @Cacheable(cacheNames = "in_charge_type")
    List<InChargeType> findAll();
    
    List<InChargeType> findByRelatedEntityTypeIntlIdAndActivIsTrue(String relatedEntityTypeIntldId);

}
