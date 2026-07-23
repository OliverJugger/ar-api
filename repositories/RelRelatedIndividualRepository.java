package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.services.access.HasAccessData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.history.RevisionRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

public interface RelRelatedIndividualRepository extends JpaRepository<RelRelatedIndividual, Integer>, JpaSpecificationExecutor<RelRelatedIndividual>, RevisionRepository<RelRelatedIndividual, Integer, Integer> {

    @HasAccessData(elemTypeIntlId = Constants.INTL_ID_ELEM_REL_IND)
    Optional<RelRelatedIndividual> findById(Integer id);

    // /!\ WE HAVE NO CHOICE TO USE UPDATE BECAUSE OF AUDIT /!\
 	@Modifying
	@Query(value = "UPDATE MDLePBS.RelRelatedIndividual SET TaskUID = NULL WHERE RelRelatedIndividualID = :relRelatedIndividualId", nativeQuery = true)
 	@Transactional
 	void unlinkTask(@Param("relRelatedIndividualId") Integer relRelatedIndividualId);
 	
 	// /!\ WE HAVE NO CHOICE TO USE UPDATE BECAUSE OF AUDIT /!\
 	@Modifying
	@Query(value = "UPDATE MDLePBS.RelRelatedIndividual SET TaskUID = :taskUid WHERE RelRelatedIndividualID = :relRelatedIndividualId", nativeQuery = true)
 	@Transactional
 	void linkTask(
 			@Param("relRelatedIndividualId") Integer relRelatedIndividualId,
 			@Param("taskUid") String taskUid);
}