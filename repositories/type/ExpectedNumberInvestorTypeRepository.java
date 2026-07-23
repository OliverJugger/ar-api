package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.ExpectedNumberInvestorType;

@Repository
public interface ExpectedNumberInvestorTypeRepository extends JpaRepository<ExpectedNumberInvestorType, Integer> {

    @Cacheable(cacheNames = "expected_number_investor_cache")
	List<ExpectedNumberInvestorType> findAll();

}
