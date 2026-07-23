package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.PersonalAssetHoldingVehicleType;

@Repository
public interface PersonalAssetHoldingVehicleTypeRepository extends JpaRepository<PersonalAssetHoldingVehicleType, Integer> {
	
    @Cacheable(cacheNames = "personal_asset_holding_vehicle_type")
    List<PersonalAssetHoldingVehicleType> findAll();
    
    Optional<PersonalAssetHoldingVehicleType> findByIntlId(String intlId);
}
