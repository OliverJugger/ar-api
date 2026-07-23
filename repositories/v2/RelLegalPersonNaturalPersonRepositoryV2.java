package com.bdl.epbs_fund_api.repositories.v2;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.relations.v2.RelLegalPersonNaturalPersonV2;

@Repository
public interface RelLegalPersonNaturalPersonRepositoryV2 extends JpaRepository<RelLegalPersonNaturalPersonV2, Integer> {
    Optional<RelLegalPersonNaturalPersonV2> findByLegalPersonIdAndNaturalPersonId(Integer legalPersonId, Integer naturalPersonId);
}
