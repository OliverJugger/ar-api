package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.relations.RelUCIRelatedIndividual;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RelUCIRelatedIndividualRepository extends JpaRepository<RelUCIRelatedIndividual, Integer> {
}
