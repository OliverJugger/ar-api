package com.bdl.epbs_fund_api.services.impl;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Predicate;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.entities.ProjectInitiator;
import com.bdl.epbs_fund_api.repositories.ProjectInitiatorRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProjectInitiatorService {

    @Autowired
    private final ProjectInitiatorRepository projectInitiatorRepository;
	
	private final Predicate<ProjectInitiator> hasAbandonnedStartDate = p -> p.getPbsAcceptanceStatusAbandonedStartDate() != null;
	private final Predicate<ProjectInitiator> hasOnboardingCompletedStartDate = p -> p.getPbsAcceptanceStatusOnboardingCompletedStartDate() != null;
	private final Predicate<ProjectInitiator> hasRejectedByCSSFStartDate = p -> p.getPbsAcceptanceStatusRejectedByCSSFStartDate() != null;
	private final Predicate<ProjectInitiator> hasApprovedByCSSFStartDate = p -> p.getPbsAcceptanceStatusApprovedByCSSFStartDate() != null;
	private final Predicate<ProjectInitiator> hasRejectedByPBACStep2StartDate = p -> p.getPbsAcceptanceStatusRejectedByPBACStep2StartDate() != null;
	private final Predicate<ProjectInitiator> hasAcceptedByPBACStep2StartDate = p -> p.getPbsAcceptanceStatusAcceptedByPBACStep2StartDate() != null;
	private final Predicate<ProjectInitiator> hasReadyForPBACStep2StartDate = p -> p.getPbsAcceptanceStatusReadyForPBACStep2StartDate() != null;
	private final Predicate<ProjectInitiator> hasReadyForFinalControlPBSStartDate = p -> p.getPbsAcceptanceStatusReadyForFinalControlPBSStartDate() != null;
	private final Predicate<ProjectInitiator> hasRejectedByPBACStep1StartDate = p -> p.getPbsAcceptanceStatusRejectedByPBACStep1StartDate() != null;
	private final Predicate<ProjectInitiator> hasAcceptedByPBACStep1StartDate = p -> p.getPbsAcceptanceStatusAcceptedByPBACStep1StartDate() != null;
	private final Predicate<ProjectInitiator> hasReadyForPBACStep1StartDate = p -> p.getPbsAcceptanceStatusReadyForPBACStep1StartDate() != null;
	private final Predicate<ProjectInitiator> hasReadyForQualityControlPBSStartDate = p -> p.getPbsAcceptanceStatusReadyForQualityControlPBSStartDate() != null;
	private final Predicate<ProjectInitiator> hasUnderAssessmentStartDate = p -> p.getPbsAcceptanceStatusUnderAssessmentStartDate() != null;
	
	private final Map<Predicate<ProjectInitiator>, String> dateFieldWithStatusValue = Map.ofEntries(
		Map.entry(hasAbandonnedStartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_ABANDONED),
		Map.entry(hasOnboardingCompletedStartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_ONBOARDING_COMPLETED),
		Map.entry(hasRejectedByCSSFStartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_REJECTED_CSSF),
		Map.entry(hasApprovedByCSSFStartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_APPROVED_CSSF),
		Map.entry(hasRejectedByPBACStep2StartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_REJECTED_PBAC_STEP_2),
		Map.entry(hasAcceptedByPBACStep2StartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_ACCEPTED_PBAC_STEP_2),
		Map.entry(hasReadyForPBACStep2StartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_READY_PBAC_STEP_2),
		Map.entry(hasReadyForFinalControlPBSStartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_READY_FINAL_CONTROL_PBS),
		Map.entry(hasRejectedByPBACStep1StartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_REJECTED_PBAC_STEP_1),
		Map.entry(hasAcceptedByPBACStep1StartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_ACCEPTED_PBAC_STEP_1),
		Map.entry(hasReadyForPBACStep1StartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_READY_PBAC_STEP_1),
		Map.entry(hasReadyForQualityControlPBSStartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_READY_QUALITY_CONTROL),
		Map.entry(hasUnderAssessmentStartDate, Constants.PBS_ACCEPTANCE_STATUS_INTL_ID_UNDER_ASSESSMENT)
	);
	
	private final List<Predicate<ProjectInitiator>> lastPbsAcceptanceStatusOrderList = new LinkedList<>(Arrays.asList(
			hasAbandonnedStartDate,
			hasOnboardingCompletedStartDate,
			hasRejectedByCSSFStartDate,
			hasApprovedByCSSFStartDate, 
			hasRejectedByPBACStep2StartDate,
			hasAcceptedByPBACStep2StartDate,
			hasReadyForPBACStep2StartDate,
			hasReadyForFinalControlPBSStartDate,
			hasRejectedByPBACStep1StartDate,
			hasAcceptedByPBACStep1StartDate,
			hasReadyForPBACStep1StartDate,
			hasReadyForQualityControlPBSStartDate,
			hasUnderAssessmentStartDate));
	
	public ProjectInitiator getProjectInitiatorByIdInternal(Integer projectId) {
		return projectInitiatorRepository.findById(projectId).orElseThrow(() -> new ResourceNotFoundException("Could not find Project Initiator with id : " + projectId));
	}

	 public Optional<String> getLastPbsAcceptanceStatus(ProjectInitiator projectInitiator) {
			return lastPbsAcceptanceStatusOrderList.stream()
							.filter(p -> p.test(projectInitiator))
							.findFirst()
							.map(dateFieldWithStatusValue::get);
	 }
}
