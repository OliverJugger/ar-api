package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.CountryCallingCodeType;

@Repository
public interface CountryCallingCodeRepository extends JpaRepository<CountryCallingCodeType, Integer> {
	
    @Cacheable(cacheNames = "country_calling_code_type")
    List<CountryCallingCodeType> findAll();
}