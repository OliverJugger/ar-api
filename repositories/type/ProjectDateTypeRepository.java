package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.ProjectDateType;

@Repository
public interface ProjectDateTypeRepository extends JpaRepository<ProjectDateType, Integer> {

    @Cacheable(cacheNames = "project_date_cache")
    List<ProjectDateType> findAll();

}
