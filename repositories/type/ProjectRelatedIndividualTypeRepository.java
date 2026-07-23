package com.bdl.epbs_fund_api.repositories.type;

import com.bdl.epbs_fund_api.model.types.ProjectRelatedIndividualType;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProjectRelatedIndividualTypeRepository extends JpaRepository<ProjectRelatedIndividualType, Integer> {

    @Cacheable(cacheNames = "project_related_individual_type")
    List<ProjectRelatedIndividualType> findAll();

    Optional<ProjectRelatedIndividualType> findByIntlId(String intlId);
}
