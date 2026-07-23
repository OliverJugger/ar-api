package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.FundLegalFormType;

@Repository
public interface EPBSFundLegalFormTypeRepository extends JpaRepository<FundLegalFormType, Integer> {
	
	@Cacheable(cacheNames = "epbs_legal_form_type")
    List<FundLegalFormType> findAll();

    Optional<FundLegalFormType> findByIntlId(String intlId);
}
