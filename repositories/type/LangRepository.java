package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;

import com.bdl.epbs_fund_api.model.types.LangType;

public interface LangRepository extends JpaRepository<LangType, Integer> {
	
	@Cacheable(cacheNames = "lang_type")
	List<LangType> findAll();

}
