package com.bdl.epbs_fund_api.services.impl;

import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_ONB_PROJECT_CREATE;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_ONB_PROJECT_GET;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_ONB_PROJECT_UPDATE_DESC;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Stream;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.authentication.UserContext;
import com.bdl.epbs_fund_api.authentication.UserService;
import com.bdl.epbs_fund_api.constants.UpdateStatus;
import com.bdl.epbs_fund_api.mappings.AbstractTypeMapper;
import com.bdl.epbs_fund_api.mappings.ProjectDescriptionMapper;
import com.bdl.epbs_fund_api.model.AbstractTypeDTO;
import com.bdl.epbs_fund_api.model.CommercialStatusDTO;
import com.bdl.epbs_fund_api.model.FundDTO;
import com.bdl.epbs_fund_api.model.FundItemDTO;
import com.bdl.epbs_fund_api.model.PbsAcceptanceCommentDTO;
import com.bdl.epbs_fund_api.model.PbsAcceptanceStatusUpdateDTO;
import com.bdl.epbs_fund_api.model.ProjectDescriptionBaseDTO;
import com.bdl.epbs_fund_api.model.ProjectDescriptionDTO;
import com.bdl.epbs_fund_api.model.ProjectInitiatorDTO;
import com.bdl.epbs_fund_api.model.ProjectProspectDTO;
import com.bdl.epbs_fund_api.model.ProjectScopeIdDTO;
import com.bdl.epbs_fund_api.model.RelProjectInitiatorSubFundDTO;
import com.bdl.epbs_fund_api.model.SubFundDTO;
import com.bdl.epbs_fund_api.model.UCIEntityDTO;
import com.bdl.epbs_fund_api.model.entities.AbstractTypeEntity;
import com.bdl.epbs_fund_api.model.entities.ProjectDescription;
import com.bdl.epbs_fund_api.model.entities.ProjectInitiator;
import com.bdl.epbs_fund_api.model.entities.ProjectProspect;
import com.bdl.epbs_fund_api.model.relations.RelProjectInitiatorSubFund;
import com.bdl.epbs_fund_api.model.types.ProjectType;
import com.bdl.epbs_fund_api.repositories.IProjectDescriptionsRepository;
import com.bdl.epbs_fund_api.repositories.type.CommercialStatusTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.ConvAMAcceptanceStatusTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.PBSAcceptanceStatusTypeRepository;
import com.bdl.epbs_fund_api.services.IProjectDescriptionService;
import com.bdl.epbs_fund_api.services.access.HasAccess;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProjectDescriptionService implements IProjectDescriptionService {

    private final IProjectDescriptionsRepository projectDescriptionsRepository;
    private final ProjectDescriptionMapper projectDescriptionMapper;
    private final CommercialStatusTypeRepository commercialStatusTypeRepository;
    private final ConvAMAcceptanceStatusTypeRepository convAMAcceptanceStatusTypeRepository;
    private final PBSAcceptanceStatusTypeRepository pbsAcceptanceStatusTypeRepository;
    private final TypeService typeService;
    private final UserService userService;
    private final FundService fundService;
    private final SubFundService subFundService;
    private final AbstractTypeMapper typeMapper;

    @HasAccess(EPBS_ROLE_ONB_PROJECT_GET)
    @Override
    public ProjectDescriptionDTO getProjectDescription(Integer id) {
        ProjectDescription projectDescription = this.projectDescriptionsRepository.findById(id).orElseThrow();
        enrichWithStatusTypes(projectDescription);
        return projectDescriptionMapper.toDTO(projectDescription);
    }

    @HasAccess(EPBS_ROLE_ONB_PROJECT_GET)
    @Override
    public List<ProjectDescriptionBaseDTO> getAllProjectDescription() {
        List<ProjectDescription> projectDescriptionList = this.projectDescriptionsRepository.findAll();
        List<AbstractTypeDTO> statuses = Stream.concat(typeService.getAllCommercialStatusType().stream(), typeService.getAllPBSAcceptanceStatusType().stream())
                .toList();
        return projectDescriptionMapper.toBaseDTOList(projectDescriptionList, statuses);
    }

    @HasAccess(EPBS_ROLE_ONB_PROJECT_CREATE)
    @Override
    public ProjectDescriptionDTO createProjectDescription(ProjectDescriptionDTO projectDescriptionDTO) {
        ProjectDescription projectDescription = projectDescriptionMapper.toEntity(projectDescriptionDTO);

        String currentUser = UserContext.getCurrentUser();
        projectDescription.setTecUser(currentUser);
        projectDescription.setCreatedBy(currentUser);

        projectDescription.setCreatedOn(LocalDateTime.now());
        projectDescription.setCommercialStatusUnderAssessmentStartDate(LocalDateTime.now());
        projectDescription.setCommercialStatusTypes(typeMapper.mapToCommercialStatusType(typeService.getAllCommercialStatusType()));

        String projectScopeIntlId = Optional.ofNullable(projectDescription.getProjectType())
                .map(ProjectType::getProjectScope)
                .map(AbstractTypeEntity::getIntlId)
                .orElse(null);

        ProjectDescription savedProjectDescription = projectDescriptionsRepository.save(projectDescription);

        if (ProjectScopeIdDTO.FUND.getValue().equals(projectScopeIntlId)) {
            savedProjectDescription.setProjectInitiator(initialiseProjectInitiator(projectDescription.getId()));
        } else if (ProjectScopeIdDTO.IIS.getValue().equals(projectScopeIntlId)
                || ProjectScopeIdDTO.ICS.getValue().equals(projectScopeIntlId)) {
            savedProjectDescription.setProjectProspect(initialiseProjectProspect(projectDescription.getId()));
        }

        ProjectDescription finalSave = projectDescriptionsRepository.save(savedProjectDescription);

        // TODO updateTechnicalTables

        return projectDescriptionMapper.toDTO(finalSave);
    }

    private ProjectInitiator initialiseProjectInitiator(Integer projectDescriptionId) {
        ProjectInitiator projectInitiator = new ProjectInitiator();
        LocalDateTime now = LocalDateTime.now();

        projectInitiator.setId(projectDescriptionId);
        projectInitiator.setConvAMAcceptanceStatusUnderAssessmentStartDate(now);
        projectInitiator.setPbsAcceptanceStatusUnderAssessmentStartDate(now);
        projectInitiator.setConvAMAcceptanceStatusTypes(typeMapper.mapToConvAMAcceptanceStatusType(typeService.getAllConvAMAcceptanceStatusType()));
        projectInitiator.setPbsAcceptanceStatusTypes(typeMapper.mapToPBSAcceptanceStatusType(typeService.getAllPBSAcceptanceStatusType()));

        return projectInitiator;
    }

    private ProjectProspect initialiseProjectProspect(Integer projectDescriptionId) {
        ProjectProspect projectProspect = new ProjectProspect();
        LocalDateTime now = LocalDateTime.now();

        projectProspect.setId(projectDescriptionId);
        projectProspect.setPbsAcceptanceStatusUnderAssessmentStartDate(now);
        projectProspect.setPbsAcceptanceStatusTypes(typeMapper.mapToPBSAcceptanceStatusType(typeService.getAllPBSAcceptanceStatusType()));

        return projectProspect;
    }

    public ProjectInitiatorDTO saveProjectInitiator(ProjectDescriptionDTO projectDescription) {
        ProjectInitiatorDTO projectInitiator = projectDescription.getProjectInitiator();
        if (projectInitiator == null) {
            return null;
        }

        projectInitiator.setId(projectDescription.getId());

        // TODO Corriger plz pour qu'on sache que "2" = projet scope : new_sub_fund : le front devrait l'envoyer au lieu de juste id:2
        String projectTypeId = projectDescription.getProjectType().getId();
        List<String> majorChangeIds = List.of("3", "11", "12");
        boolean isMajorChange = majorChangeIds.contains(projectTypeId);
        boolean isMajorChangeOrSubFund = isMajorChange || "2".equals(projectTypeId);

        Optional<FundDTO> fund = Optional.ofNullable(projectInitiator.getFund())
                .map(projectInitiatorFund -> {
                    FundDTO saved;
                    if (projectInitiatorFund.getFundId() == null) {
                        LocalDateTime uciEntityStartDate = LocalDateTime.now();
                        saved = fundService.createFund(projectInitiatorFund, uciEntityStartDate);
                    } else if (isMajorChangeOrSubFund) {
                        saved = fundService.getFund(Integer.valueOf(projectInitiatorFund.getFundId()));
                    } else {
                    	FundDTO actualFund = fundService.getFund(Integer.valueOf(projectInitiatorFund.getFundId()));
                    	projectInitiatorFund.setRiskCategory(actualFund.getRiskCategory()); 
                        saved = fundService.updateFund(Integer.valueOf(projectInitiatorFund.getFundId()), projectInitiatorFund);
                    }
                    return saved;
                });
        fund.ifPresent(projectInitiator::setFund);

        List<RelProjectInitiatorSubFundDTO> relations = Optional.ofNullable(projectInitiator.getSubFunds())
                .orElse(Collections.emptyList())
                .stream()
                .map(rel -> {
                    AtomicReference<SubFundDTO> saved = new AtomicReference<>();

                    Optional.ofNullable(rel.getSubFund())
                            .ifPresent(subFundDTO -> {
                                fund.ifPresent(fundDTO -> rel.getSubFund().setFund(new FundItemDTO().fundId(fundDTO.getFundId())));
                                if (subFundDTO.getId() == null) {
                                    saved.set(subFundService.createSubFund(rel.getSubFund()));
                                } else if (isMajorChange) {
                                    saved.set(subFundService.getSubFundById(Integer.valueOf(subFundDTO.getId())));
                                } else {
                                	SubFundDTO actualSubFund = subFundService.getSubFundById(Integer.valueOf(subFundDTO.getId()));
                                	SubFundDTO projectInitiatorSubFund = rel.getSubFund();
                                	projectInitiatorSubFund.setRiskCategory(actualSubFund.getRiskCategory());
                                    saved.set(subFundService.updateSubFund(Integer.valueOf(subFundDTO.getId()), projectInitiatorSubFund));
                                }
                            });

                    rel.setSubFund(saved.get());
                    return rel;
                })
                .toList();

        projectInitiator.setSubFunds(relations);
        return projectInitiator;
    }

    public ProjectProspectDTO saveProjectProspect(ProjectDescriptionDTO projectDescription) {
        ProjectProspectDTO projectProspectDTO = projectDescription.getProjectProspect();
        if (projectProspectDTO == null) {
            return null;
        }

        projectProspectDTO.setId(projectDescription.getId());

        return projectProspectDTO;
    }

    @Transactional
    @HasAccess(EPBS_ROLE_ONB_PROJECT_UPDATE_DESC)
    @Override
    public ProjectDescriptionDTO updateProjectDescription(Integer id, ProjectDescriptionDTO projectDescriptionDTO) {
        projectDescriptionDTO.setOwnerBdlUser(userService.findOrCreate(projectDescriptionDTO.getOwnerBdlUser()));
        projectDescriptionDTO.setOwnerRmUser(userService.findOrCreate(projectDescriptionDTO.getOwnerRmUser()));
        projectDescriptionDTO.setPbacStep1Submitter(userService.findOrCreate(projectDescriptionDTO.getPbacStep1Submitter()));
        projectDescriptionDTO.setPbacStep2Submitter(userService.findOrCreate(projectDescriptionDTO.getPbacStep2Submitter()));

        Optional.ofNullable(projectDescriptionDTO.getProjectInitiator())
                .ifPresent(projectInitiatorDTO -> saveProjectInitiator(projectDescriptionDTO));
        Optional.ofNullable(projectDescriptionDTO.getProjectProspect())
                .ifPresent(projectProspectDTO -> saveProjectProspect(projectDescriptionDTO));

        List<FundDTO> relatedFunds = Optional.ofNullable(projectDescriptionDTO.getRelatedFunds())
                .orElse(Collections.emptyList())
                .stream()
                .map(FundDTO::getUciEntity)
                .map(UCIEntityDTO::getId)
                .filter(Objects::nonNull)
                .map(Integer::valueOf)
                .map(fundService::getFund)
                .toList();

        projectDescriptionDTO.setRelatedFunds(relatedFunds);

        List<SubFundDTO> relatedSubFunds = Optional.ofNullable(projectDescriptionDTO.getRelatedSubFunds())
                .orElse(Collections.emptyList())
                .stream()
                .map(SubFundDTO::getUciEntity)
                .map(UCIEntityDTO::getId)
                .filter(Objects::nonNull)
                .map(Integer::valueOf)
                .map(subFundService::getSubFundById)
                .toList();

        projectDescriptionDTO.setRelatedSubFunds(relatedSubFunds);

        ProjectDescription projectDescription = projectDescriptionMapper.toEntity(projectDescriptionDTO);

        // FIXME do this in the mapper
        Optional.ofNullable(projectDescription.getProjectProspect()).ifPresent(projectProspect -> {
            projectProspect.getAccounts().forEach(relProjectProspectAccountType -> relProjectProspectAccountType.setProjectProspect(projectDescription.getProjectProspect()));
        });

        String currentUser = UserContext.getCurrentUser();
        projectDescription.setTecUser(currentUser);
        projectDescription.setUpdatedBy(currentUser);
        projectDescription.setCreatedBy(currentUser);

        projectDescription.setUpdatedOn(LocalDateTime.now());
        Optional.ofNullable(projectDescription.getRelProjectRelatedIndividual())
                .orElse(Collections.emptyList())
                .forEach(relProjectRelatedIndividual -> {
                    relProjectRelatedIndividual.setNaturalPersonId(relProjectRelatedIndividual.getNaturalPerson().getId());
                    relProjectRelatedIndividual.setProjectId(projectDescription.getId());
                });

        this.enrichRelations(projectDescription);

        ProjectDescription saved = projectDescriptionsRepository.save(projectDescription);

        // TODO updateTechnicalTables

        enrichWithStatusTypes(saved);

        return projectDescriptionMapper.toDTO(saved);
    }
    
    @Override
    public ProjectDescriptionDTO updateProjectCommercialStatus(Integer projectId, CommercialStatusDTO commercialStatus) {
        Optional<ProjectDescription> projectDescription = projectDescriptionsRepository.findById(projectId);
        return projectDescription
                .map(project -> updateProjectCommercialStatus(project, commercialStatus))
                .map(projectDescriptionsRepository::save)
                .map(projectDescriptionMapper::toDTO)
                .orElse(null);
    }

    @Override
    public List<ProjectDescriptionDTO> getAllProjects(List<Integer> ids) {
        List<ProjectDescription> projects = projectDescriptionsRepository.findAllById(ids);
        projects.forEach(this::enrichWithStatusTypes);
        return projectDescriptionMapper.toDTO(projects);
    }

    @Override
    public ProjectDescriptionDTO updateProjectDescriptionComment(Integer id, PbsAcceptanceCommentDTO pbsAcceptanceCommentDTO) {
        Optional<ProjectDescription> projectDescription = projectDescriptionsRepository.findById(id);
        return projectDescription
                .map(pd -> updateProjectComment(pd, pbsAcceptanceCommentDTO))
                .map(projectDescriptionsRepository::save)
                .map(projectDescriptionMapper::toDTO)
                .orElse(null);
    }

    private void enrichRelations(ProjectDescription projectDescription) {
        Optional.ofNullable(projectDescription)
                .map(ProjectDescription::getProjectInitiator)
                .map(ProjectInitiator::getSubFunds)
                .orElse(Collections.emptyList())
                .forEach(this::enrichRelationsSubFunds);
    }

    private void enrichRelationsSubFunds(RelProjectInitiatorSubFund relProjectInitiatorSubFund) {
        Optional.ofNullable(relProjectInitiatorSubFund)
                .map(RelProjectInitiatorSubFund::getSubFundInvestorBases)
                .orElse(Collections.emptyList())
                .forEach(relProjectInitiatorSubFundInvestorBaseType -> relProjectInitiatorSubFundInvestorBaseType.setRelProjectInitiatorSubFund(relProjectInitiatorSubFund));
    }

    @Override
    public ProjectDescriptionDTO updateProjectDescriptionStatus(Integer id, PbsAcceptanceStatusUpdateDTO pbsAcceptanceStatusUpdateDTO) {
        Optional<ProjectDescription> projectDescription = projectDescriptionsRepository.findById(id);

        return projectDescription
                .map(pd -> updateProjectStatus(pd, pbsAcceptanceStatusUpdateDTO))
                .map(pd -> {
                    ProjectDescription pdSaved = projectDescriptionsRepository.save(pd);
                    enrichWithStatusTypes(pdSaved);
                    return pdSaved;
                })
                .map(projectDescriptionMapper::toDTO)
                .orElse(null);
    }

    private ProjectDescription updateProjectStatus(ProjectDescription projectDescription, PbsAcceptanceStatusUpdateDTO pbsAcceptanceStatusUpdateDTO) {
        Optional.ofNullable(projectDescription)
                .map(ProjectDescription::getProjectProspect)
                .map(pp -> updateProjectProspectPbsAcceptanceStatus(pp, pbsAcceptanceStatusUpdateDTO.getPbsAcceptanceStatus()))
                .ifPresent(projectDescription::setProjectProspect);

        Optional.ofNullable(projectDescription)
                .map(ProjectDescription::getProjectInitiator)
                .map(pi -> updateProjectInitiatorPbsAcceptanceStatus(pi, pbsAcceptanceStatusUpdateDTO.getPbsAcceptanceStatus()))
                .ifPresent(projectDescription::setProjectInitiator);

        return projectDescription;
    }

    private ProjectDescription updateProjectComment(ProjectDescription projectDescription, PbsAcceptanceCommentDTO pbsAcceptanceCommentDTO) {
        var commentType = pbsAcceptanceCommentDTO.getCommentType();
        switch (commentType) {
            case STEP1_VALIDATOR1 -> {
                projectDescription.setPbacStep1Validator1User(pbsAcceptanceCommentDTO.getUserIdm());
                projectDescription.setPbacStep1Validator1Comment(pbsAcceptanceCommentDTO.getComment());
            }
            case STEP1_VALIDATOR2 -> {
                projectDescription.setPbacStep1Validator2User(pbsAcceptanceCommentDTO.getUserIdm());
                projectDescription.setPbacStep1Validator2Comment(pbsAcceptanceCommentDTO.getComment());
            }
            case STEP1_VALIDATOR3 -> {
                projectDescription.setPbacStep1Validator3User(pbsAcceptanceCommentDTO.getUserIdm());
                projectDescription.setPbacStep1Validator3Comment(pbsAcceptanceCommentDTO.getComment());
            }
            case STEP2_VALIDATOR1 -> {
                projectDescription.setPbacStep2ValidatorUser(pbsAcceptanceCommentDTO.getUserIdm());
                projectDescription.setPbacStep2ValidatorComment(pbsAcceptanceCommentDTO.getComment());
            }
            default -> log.warn("WARN : Unknown comment type, the comment has not been updated");
        }
        return projectDescription;
    }
    
    private ProjectDescription updateProjectCommercialStatus(ProjectDescription project, CommercialStatusDTO commercialStatus) {
    	LocalDateTime date = commercialStatus.getDate();
    	switch (commercialStatus.getStatus()) {
    		case UNDER_ASSESSMENT -> project.setCommercialStatusUnderAssessmentStartDate(date);
    		case UNDER_CLIENT_OFFERING -> project.setCommercialStatusUnderClientOfferingStartDate(date);
    		case ON_HOLD -> project.setCommercialStatusOnHoldStartDate(date);
    		case ABANDONED -> project.setCommercialStatusAbandonedStartDate(date);
    		case DECLINED -> project.setCommercialStatusDeclinedStartDate(date);
    		case WON -> project.setCommercialStatusWonStartDate(date);
    		case LOST -> project.setCommercialStatusLostStartDate(date);
        }
    	return project;
    }

    private ProjectProspect updateProjectProspectPbsAcceptanceStatus(ProjectProspect projectProspect, String status) {
        if (UpdateStatus.ACCEPTED_PBAC_STEP_1.value.equals(status)) {
            projectProspect.setPbsAcceptanceStatusAcceptedByPBACStep1StartDate(LocalDateTime.now());
        } else if (UpdateStatus.REJECTED_PBAC_STEP_1.value.equals(status)) {
            projectProspect.setPbsAcceptanceStatusRejectedByPBACStep1StartDate(LocalDateTime.now());
        } else if (UpdateStatus.READY_PBAC_STEP_1.value.equals(status)) {
            projectProspect.setPbsAcceptanceStatusReadyForPBACStep1StartDate(LocalDateTime.now());
        } else if (UpdateStatus.ACCEPTED_PBAC_STEP_2.value.equals(status)) {
            projectProspect.setPbsAcceptanceStatusAcceptedByPBACStep2StartDate(LocalDateTime.now());
        } else if (UpdateStatus.REJECTED_PBAC_STEP_2.value.equals(status)) {
            projectProspect.setPbsAcceptanceStatusRejectedByPBACStep2StartDate(LocalDateTime.now());
        } else if (UpdateStatus.READY_PBAC_STEP_2.value.equals(status)) {
            projectProspect.setPbsAcceptanceStatusReadyForPBACStep2StartDate(LocalDateTime.now());
        } else if (UpdateStatus.ACCOUNT_OPENED.value.equals(status)) {
            projectProspect.setPbsAcceptanceStatusAccountOpenedStartDate(LocalDateTime.now());
        } else if (UpdateStatus.ONBOARDING_COMPLETED.value.equals(status)) {
            projectProspect.setPbsAcceptanceStatusOnboardingCompletedStartDate(LocalDateTime.now());
        } else if (UpdateStatus.ABANDON_PBAC.value.equals(status)) {
            projectProspect.setPbsAcceptanceStatusAbandonedStartDate(LocalDateTime.now());
        }
        return projectProspect;
    }

    public ProjectInitiator updateProjectInitiatorPbsAcceptanceStatus(ProjectInitiator projectInitiator, String status) {
        if (UpdateStatus.ACCEPTED_PBAC_STEP_1.value.equals(status)) {
            projectInitiator.setPbsAcceptanceStatusAcceptedByPBACStep1StartDate(LocalDateTime.now());
        } else if (UpdateStatus.REJECTED_PBAC_STEP_1.value.equals(status)) {
            projectInitiator.setPbsAcceptanceStatusRejectedByPBACStep1StartDate(LocalDateTime.now());
        } else if (UpdateStatus.READY_PBAC_STEP_1.value.equals(status)) {
            projectInitiator.setPbsAcceptanceStatusReadyForPBACStep1StartDate(LocalDateTime.now());
        } else if (UpdateStatus.ACCEPTED_PBAC_STEP_2.value.equals(status)) {
            projectInitiator.setPbsAcceptanceStatusAcceptedByPBACStep2StartDate(LocalDateTime.now());
        } else if (UpdateStatus.REJECTED_PBAC_STEP_2.value.equals(status)) {
            projectInitiator.setPbsAcceptanceStatusRejectedByPBACStep2StartDate(LocalDateTime.now());
        } else if (UpdateStatus.READY_PBAC_STEP_2.value.equals(status)) {
            projectInitiator.setPbsAcceptanceStatusReadyForPBACStep2StartDate(LocalDateTime.now());
        } else if (UpdateStatus.ONBOARDING_COMPLETED.value.equals(status)) {
            projectInitiator.setPbsAcceptanceStatusOnboardingCompletedStartDate(LocalDateTime.now());
        } else if (UpdateStatus.ABANDON_PBAC.value.equals(status)) {
            projectInitiator.setPbsAcceptanceStatusAbandonedStartDate(LocalDateTime.now());
        }
        return projectInitiator;
    }

    public List<IProjectDescriptionsRepository.ProjectDescriptionNameId> findByFundId(Integer fundId) {
     return projectDescriptionsRepository.findByProjectInitiator_FundId(fundId);
    }

    private void enrichWithStatusTypes(ProjectDescription projectDescription) {

        Optional<ProjectDescription> optionalProjectDescription = Optional.ofNullable(projectDescription);

        optionalProjectDescription
                .map(ProjectDescription::getProjectInitiator)
                .ifPresent(projectInitiator -> {
                    projectInitiator.setConvAMAcceptanceStatusTypes(convAMAcceptanceStatusTypeRepository.findAll());
                    projectInitiator.setPbsAcceptanceStatusTypes(pbsAcceptanceStatusTypeRepository.findAll());
                });

        optionalProjectDescription
                .map(ProjectDescription::getProjectProspect)
                .ifPresent(projectProspect -> {
                    projectProspect.setPbsAcceptanceStatusTypes(pbsAcceptanceStatusTypeRepository.findAll());
                });

        optionalProjectDescription.ifPresent(projectDescr -> {
            projectDescr.setCommercialStatusTypes(commercialStatusTypeRepository.findAll());
        });
    }
}