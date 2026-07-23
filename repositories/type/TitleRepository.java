package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;

import com.bdl.epbs_fund_api.model.types.TitleType;

/**
 * @author JAMZAR5
 *
 */
public interface TitleRepository extends JpaRepository<TitleType, Integer> {
	
    @Cacheable(cacheNames = "title_type")
    List<TitleType> findAll();

}
