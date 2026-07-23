package com.bdl.epbs_fund_api.repositories.v2;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.relations.v2.RelLegalPersonRelatedIndividualV2;

@Repository
public interface RelLegalPersonRelatedIndividualRepositoryV2 extends JpaRepository<RelLegalPersonRelatedIndividualV2, Integer> {
}
