package com.bdl.epbs_fund_api.repositories.access;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.access.AuditLogModel;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLogModel, Integer> {
	
	/**
	 * List all created or modified sub-funds during the five last days.
	 * 
	 */
	@Query("SELECT DISTINCT model "
			+ "FROM AuditLogModel model "
			+ "INNER JOIN model.auditActionType actionType "
			+ "INNER JOIN model.elemType elemType "
			+ "WHERE actionType.intlId IN ('create', 'upd') "
			+ "AND elemType.intlId = 'sbfund' "
			+ "AND CAST(model.timeStamp as date) >= DATEADD(DAY, -5, CURRENT_DATE) ")
	List<AuditLogModel> findCreatedOrUpdatedSubFund();
	
	/**
	 * List all created or modified funds during the five last days.
	 *
	 */
	@Query("SELECT DISTINCT model FROM AuditLogModel model "
			+ "INNER JOIN model.auditActionType actionType "
			+ "INNER JOIN model.elemType elemType "
			+ "WHERE actionType.intlId in ('create', 'upd') AND elemType.intlId = 'fund' "
			+ "AND CAST(model.timeStamp as date) >= DATEADD(DAY, -5, CURRENT_DATE) ")
	List<AuditLogModel> findCreatedOrUpdatedFund();
	
	/**
	 * List all created or modified relRelatedEntity during the five last days.
	 * 
	 */
	@Query("SELECT DISTINCT model FROM AuditLogModel model "
			+ "INNER JOIN model.auditActionType actionType "
			+ "INNER JOIN model.elemType elemType "
			+ "WHERE actionType.intlId in ('create', 'upd') AND elemType.intlId = 'rel_ent' "
			+ "AND CAST(model.timeStamp as date) >= DATEADD(DAY, -5, CURRENT_DATE) ")
	List<AuditLogModel> findCreatedOrUpdatedRelRelatedEntity();
}
