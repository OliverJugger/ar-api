package com.bdl.epbs_fund_api.repositories;

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
import com.bdl.epbs_fund_api.model.relations.RelRelatedEntity;
import com.bdl.epbs_fund_api.services.access.HasAccessData;

@Repository
public interface RelRelatedEntityRepository extends JpaRepository<RelRelatedEntity, Integer>, JpaSpecificationExecutor<RelRelatedEntity>, RevisionRepository<RelRelatedEntity, Integer, Integer> {

	@HasAccessData(elemTypeIntlId = Constants.INTL_ID_ELEM_REL_ENT)
	Optional<RelRelatedEntity> findById(Integer id);
	
	// /!\ WE HAVE NO CHOICE TO USE UPDATE BECAUSE OF AUDIT /!\
	@Modifying
	@Query(value = "UPDATE MDLePBS.RelRelatedEntity SET TaskUID = NULL WHERE RelRelatedEntityID = :relRelatedEntityId", nativeQuery = true)
	@Transactional
	void unlinkTask(@Param("relRelatedEntityId") Integer relRelatedEntityId);
	
	// /!\ WE HAVE NO CHOICE TO USE UPDATE BECAUSE OF AUDIT /!\
	@Modifying
	@Query(value = "UPDATE MDLePBS.RelRelatedEntity SET TaskUID = :taskUid WHERE RelRelatedEntityID = :relRelatedEntityId", nativeQuery = true)
	@Transactional
	void linkTask(
			@Param("relRelatedEntityId") Integer relRelatedEntityId,
			@Param("taskUid") String taskUid);
		
}
