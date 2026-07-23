package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.relations.RelUCINaturalPerson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RelUCINaturalPersonRepository extends JpaRepository<RelUCINaturalPerson, Integer> {

    Optional<RelUCINaturalPerson> findByUciEntityIdAndNaturalPersonId(Integer uciEntityId, Integer NaturalPersonId);

}