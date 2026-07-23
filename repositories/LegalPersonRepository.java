package com.bdl.epbs_fund_api.repositories;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.history.RevisionRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.entities.LegalPerson;

@Repository
public interface LegalPersonRepository extends JpaRepository<LegalPerson, Integer>, RevisionRepository<LegalPerson, Integer, Integer> {
    List<LegalPerson> findByLegalNameContaining(String nameContains, Pageable pageable);
    
    // FOR EPBS LIGHT OBJECTS search by name //
 	interface LegalPersonLegalNameId {
 		String getId();
 		String getLegalName();
 	}
 	List<LegalPersonLegalNameId> findAllLegalNameIdByIdIn(List<Integer> ids);
    List<LegalPersonLegalNameId> findAllLegalNameIdByLegalNameContaining(String legalName);
}
