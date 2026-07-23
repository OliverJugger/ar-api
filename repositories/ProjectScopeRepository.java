package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.ProjectScope;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProjectScopeRepository extends JpaRepository<ProjectScope,Integer> {

    @Cacheable(cacheNames = "project-scope")
    List<ProjectScope> findAll();

    Optional<ProjectScope> findByIntlId(String intlId);
}

