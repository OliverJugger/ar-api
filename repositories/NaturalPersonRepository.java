package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.entities.NaturalPerson;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NaturalPersonRepository extends JpaRepository<NaturalPerson, Integer> {
    List<NaturalPerson> findNaturalPersonByFirstNameContainsOrLastNameContainsOrFirstNameContainsOrLastNameContains(String firstNameContains1, String lastNameContains1, String firstNameContains2, String lastNameContains2, Pageable pageable);
   
    
    // FOR EPBS LIGHT OBJECTS search by name //
  	interface NaturalPersonFirstNameLastNameId {
  		String getId();
  		String getFirstName();
  		String getLastName();
  	}
  	 List<NaturalPersonFirstNameLastNameId> findAllFirstNameLastNameIdByIdIn(List<Integer> ids);
    List<NaturalPersonFirstNameLastNameId> findAllFirstNameLastNameIdByFirstNameContainsOrLastNameContains(String firstNameContains, String lastNameContains);
}