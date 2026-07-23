package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.types.ProjectType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProjectTypeRepository extends JpaRepository<ProjectType, Integer> {

    Optional<ProjectType> findByIntlId(String intlId);
}
