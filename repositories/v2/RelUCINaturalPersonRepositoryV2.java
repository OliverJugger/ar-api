package com.bdl.epbs_fund_api.repositories.v2;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.relations.v2.RelUCINaturalPersonV2;

@Repository
public interface RelUCINaturalPersonRepositoryV2 extends JpaRepository<RelUCINaturalPersonV2, Integer> {
    Optional<RelUCINaturalPersonV2> findByUciEntityIdAndNaturalPersonId(Integer uciEntityId, Integer naturalPersonId);
}