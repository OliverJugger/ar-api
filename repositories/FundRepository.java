package com.bdl.epbs_fund_api.repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.history.RevisionRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.entities.Fund;
import com.bdl.epbs_fund_api.services.access.HasAccessData;

@Repository
public interface FundRepository extends JpaRepository<Fund, Integer>, JpaSpecificationExecutor<Fund>, RevisionRepository<Fund, Integer, Integer> {

	@HasAccessData(elemTypeIntlId = Constants.INTL_ID_ELEM_FUND)
	Optional<Fund> findById(Integer id);

	@Modifying
	@Query(value = "UPDATE MDLePBS.Fund SET PersonID = :personId WHERE FundID = :fundId", nativeQuery = true)
	@Transactional
	void updatePerson(@Param("personId") String personId, @Param("fundId") Integer fundId);

	// /!\ WE HAVE NO CHOICE TO USE UPDATE BECAUSE OF AUDIT /!\
	@Modifying
	@Query(value = "UPDATE MDLePBS.Fund SET TaskUID = NULL WHERE FundID = :fundId", nativeQuery = true)
	@Transactional
	void unlinkTask(@Param("fundId") Integer fundId);

	// /!\ WE HAVE NO CHOICE TO USE UPDATE BECAUSE OF AUDIT /!\
	@Modifying
	@Query(value = "UPDATE MDLePBS.Fund SET TaskUID = :taskUid WHERE FundID = :fundId", nativeQuery = true)
	@Transactional
	void linkTask(@Param("fundId") Integer fundId, @Param("taskUid") String taskUid);
	
	interface FundLegalName {
		String getLegalName();
	}
	
	Optional<FundLegalName> findLegalNameById(Integer id);

    // FOR EPBS LIGHT OBJECTS (old RELATED OBJECTS) //
	interface FundLegalNameId {
		String getId();
		String getLegalName();
	}
	List<FundLegalNameId> findAllLegalNameIdByIdIn(List<Integer> ids);
	List<FundLegalNameId> findAllLegalNameIdByLegalNameContaining(String legalName);
}
