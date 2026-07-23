package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.GenderType;

@Repository
public interface GenderTypeRepository extends JpaRepository<GenderType, Integer> {
	
	@Cacheable(cacheNames = "gender_type")
	List<GenderType> findAll();

}
