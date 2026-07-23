package com.bdl.epbs_fund_api.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.relations.RelUCILegalPerson;

@Repository
public interface RelUCILegalPersonRepository extends JpaRepository<RelUCILegalPerson, Integer> {
	Optional<RelUCILegalPerson> findByLegalPersonIdAndUciEntityId(Integer legalPersonId, Integer uciEntityId);
}
