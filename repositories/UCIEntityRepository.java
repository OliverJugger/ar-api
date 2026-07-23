package com.bdl.epbs_fund_api.repositories;

import org.springframework.data.jpa.repository.JpaRepository;

import com.bdl.epbs_fund_api.model.entities.UCIEntity;

public interface UCIEntityRepository extends JpaRepository<UCIEntity, Integer> {
}