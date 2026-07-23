package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.EPBSCorpEntityLegalFormType;

@Repository
public interface EPBSCorpEntityLegalFormTypeRepository extends JpaRepository<EPBSCorpEntityLegalFormType, Integer> {
	
    @Cacheable(cacheNames = "epbs_corp_entity_legal_form_type")
    List<EPBSCorpEntityLegalFormType> findAll();
	
}
