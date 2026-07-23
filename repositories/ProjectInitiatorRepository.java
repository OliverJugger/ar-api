package com.bdl.epbs_fund_api.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.entities.ProjectInitiator;

@Repository
public interface ProjectInitiatorRepository  extends JpaRepository<ProjectInitiator, Integer> {}
