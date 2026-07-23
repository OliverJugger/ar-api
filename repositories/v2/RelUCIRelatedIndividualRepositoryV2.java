package com.bdl.epbs_fund_api.repositories.v2;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.relations.v2.RelUCIRelatedIndividualV2;

@Repository
public interface RelUCIRelatedIndividualRepositoryV2 extends JpaRepository<RelUCIRelatedIndividualV2, Integer> {
}
