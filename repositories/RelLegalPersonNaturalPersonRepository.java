package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.relations.RelLegalPersonNaturalPerson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RelLegalPersonNaturalPersonRepository extends JpaRepository<RelLegalPersonNaturalPerson, Integer> {

    Optional<RelLegalPersonNaturalPerson> findByLegalPersonIdAndNaturalPersonId(Integer legalPersonId, Integer naturalPersonId);

}
