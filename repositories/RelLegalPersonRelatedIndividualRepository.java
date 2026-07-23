package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.relations.RelLegalPersonRelatedIndividual;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RelLegalPersonRelatedIndividualRepository extends JpaRepository<RelLegalPersonRelatedIndividual, Integer> {
}
