package com.bdl.epbs_fund_api.services.access.impl;

import com.bdl.epbs_fund_api.model.SubFundDTO;
import com.bdl.epbs_fund_api.model.access.AuditLogModel;
import com.bdl.epbs_fund_api.repositories.access.AuditLogRepository;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.services.impl.SubFundService;
import jakarta.transaction.Transactional;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Component
@Log4j2
public class AuditLogService {
	
	private final TechnicalAccessService technicalAccessService;

	private final AuditLogRepository auditLogRepository;
	
	private final SubFundService subFundService;

	public AuditLogService(TechnicalAccessService technicalAccessService, AuditLogRepository auditLogRepository, @Lazy SubFundService subFundService) {
		this.technicalAccessService = technicalAccessService;
		this.auditLogRepository = auditLogRepository;
		this.subFundService = subFundService;
	}
	
	@Transactional
	public List<SubFundDTO> getRecentlyModifiedSubFunds() {
		log.debug("AuditLogServiceImpl::getRecentlyCreatedOrModifiedSubFunds");
		
		List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();
		if (!dataProfilesUserIntlId.isEmpty()) {
			List<AuditLogModel> listAuditLog = auditLogRepository.findCreatedOrUpdatedSubFund();
			
			List<SubFundDTO> recentlyCreatedOrUpdatedSubFunds = new ArrayList<>();
			if(listAuditLog != null) {
				listAuditLog.stream().forEach(auditLog ->
					Optional.ofNullable(subFundService.getSubFundById(auditLog.getElemId()))
					.ifPresent(recentlyCreatedOrUpdatedSubFunds::add));
			}
			
			return recentlyCreatedOrUpdatedSubFunds
					.stream()
					.distinct()
					.collect(Collectors.toList());
		}
		return new ArrayList<>();
	}
	
	@Transactional
	public List<SubFundDTO> getRecentlyModifiedSubFundsByFund() {
		log.debug("AuditLogServiceImpl.getModifiedSubFundsByFund");
		
		List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();
		if (!dataProfilesUserIntlId.isEmpty()) {
			//First get the recently modified funds
			List<AuditLogModel> listAuditLog = auditLogRepository.findCreatedOrUpdatedFund();
			
			//Then get the related sub-funds
			List<SubFundDTO> recentlyModifiedSubFundsByFund = new ArrayList<>();
			if(listAuditLog != null) {
				listAuditLog.stream().forEach(auditLog ->
					Optional.ofNullable(subFundService.getAllSubFunds(null, auditLog.getElemId(), 100))
						.ifPresent(recentlyModifiedSubFundsByFund::addAll)
				);
			}
		
			return recentlyModifiedSubFundsByFund
					.stream()
					.distinct()
					.collect(Collectors.toList());
		}
		return new ArrayList<>();
	}

	@Transactional
	public List<SubFundDTO> getRecentlyModifiedSubFundsByRelRelatedEntity() {
		log.debug("AuditLogServiceImpl.getRecentlyModifiedSubFundsByRelRelatedEntity");
		
		List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();
		if (!dataProfilesUserIntlId.isEmpty()) {
			//First get the recently modified relRelatedEntities
			List<AuditLogModel> listAuditLog = auditLogRepository.findCreatedOrUpdatedRelRelatedEntity();
			
			//Then get the "related" sub-funds
			List<SubFundDTO> recentlyModifiedSubFundsByRelRelatedEntity = new ArrayList<>();
			if(listAuditLog != null) {
				listAuditLog.stream().forEach(auditLog ->
					Optional.ofNullable(subFundService.findByRelationFOrSFId(auditLog.getElemId()))
					.ifPresent(recentlyModifiedSubFundsByRelRelatedEntity::addAll)
				);
			}
			
			return recentlyModifiedSubFundsByRelRelatedEntity
					.stream()
					.distinct()
					.collect(Collectors.toList());
		}
		return new ArrayList<>();
	}

}
