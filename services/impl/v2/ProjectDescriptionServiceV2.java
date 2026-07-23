package com.bdl.epbs_fund_api.services.impl.v2;

import com.bdl.epbs_fund_api.authentication.UserContext;
import com.bdl.epbs_fund_api.mappings.AbstractTypeMapper;
import com.bdl.epbs_fund_api.mappings.v2.ProjectDescriptionMapperV2;
import com.bdl.epbs_fund_api.model.*;
import com.bdl.epbs_fund_api.model.entities.ProjectDescription;
import com.bdl.epbs_fund_api.model.entities.ProjectInitiator;
import com.bdl.epbs_fund_api.model.entities.ProjectProspect;
import com.bdl.epbs_fund_api.model.relations.RelProjectInitiatorSubFund;
import com.bdl.epbs_fund_api.model.relations.RelProjectRelatedIndividual;
import com.bdl.epbs_fund_api.model.types.ProjectRelatedIndividualType;
import com.bdl.epbs_fund_api.repositories.IProjectDescriptionsRepository;
import com.bdl.epbs_fund_api.repositories.type.BusinessUnitTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.ProjectRelatedIndividualTypeRepository;
import com.bdl.epbs_fund_api.services.access.HasAccess;
import com.bdl.epbs_fund_api.services.impl.*;
import com.bdl.utils.exceptions.BadRequestException;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections.CollectionUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import static com.bdl.epbs_fund_api.constants.Constants.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProjectDescriptionServiceV2 {

    private final IProjectDescriptionsRepository projectDescriptionsRepository;
    private final ProjectDescriptionMapperV2 projectDescriptionMapperV2;
    private final TypeService typeService;
    private final FundService fundService;
    private final SubFundService subFundService;
    private final NaturalPersonService naturalPersonService;
    private final LegalPersonService legalPersonService;
    private final AbstractTypeMapper typeMapper;
    private final BusinessUnitTypeRepository businessUnitTypeRepository;
    private final ProjectRelatedIndividualTypeRepository projectRelatedIndividualTypeRepository;


    @HasAccess(EPBS_ROLE_ONB_PROJECT_CREATE)
    public ProjectDescriptionV2DTO createProjectDescription(ProjectDescriptionV2DTO projectDescriptionV2DTO) {
        String projectScopeIntlId = projectDescriptionV2DTO.getScope().getValue();
        if (ProjectScopeIdDTO.FUND.getValue().equals(projectScopeIntlId) &&
                (projectDescriptionV2DTO.getFund() == null || CollectionUtils.isEmpty(projectDescriptionV2DTO.getSubFunds()))) {
            throw new BadRequestException("In case of project type \"FUND\", fund and subFunds objects are required.");
        }

        ProjectDescription projectDescription = projectDescriptionMapperV2.toEntity(projectDescriptionV2DTO);

        projectDescription.setCreatedOn(LocalDateTime.now());
        projectDescription.setRequestDate(LocalDateTime.now());
        projectDescription.setCommercialStatusUnderAssessmentStartDate(LocalDateTime.now());
        projectDescription.setCommercialStatusTypes(typeMapper.mapToCommercialStatusType(typeService.getAllCommercialStatusType()));

        String currentUser = UserContext.getCurrentUser();
        projectDescription.setTecUser(currentUser);
        projectDescription.setCreatedBy(currentUser);

        ProjectDescription savedProjectDescription = projectDescriptionsRepository.save(projectDescription);

        if (ProjectScopeIdDTO.FUND.getValue().equals(projectScopeIntlId)) {
            savedProjectDescription.setProjectInitiator(initialiseProjectInitiator(savedProjectDescription.getId(), projectDescriptionV2DTO));

            FundDTO fund = createOrFetchFund(projectDescriptionV2DTO);

            savedProjectDescription.getProjectInitiator().setFundId(Integer.valueOf(fund.getFundId()));
            savedProjectDescription.getProjectInitiator().setFund(fundService.getFundEntity(Integer.valueOf(fund.getFundId())));

            savedProjectDescription.getProjectInitiator().setSubFunds(projectDescriptionV2DTO.getSubFunds().stream().map(subfund -> {
                        SubFundDTO sf = new SubFundDTO().legalName(subfund.getLegalName()).fund(new FundItemDTO().fundId(fund.getFundId()));
                        sf = subFundService.createSubFund(sf);

                        RelProjectInitiatorSubFund rel = new RelProjectInitiatorSubFund();
                        rel.setProject(savedProjectDescription.getProjectInitiator());
                        rel.setSubFundId(Integer.valueOf(sf.getId()));
                        rel.setSubFund(subFundService.getSubFundEntity(Integer.valueOf(sf.getId())));

                        return rel;
                    }
            ).collect(Collectors.toList()));
        } else if (ProjectScopeIdDTO.IIS.getValue().equals(projectScopeIntlId)
                || ProjectScopeIdDTO.ICS.getValue().equals(projectScopeIntlId)) {
            savedProjectDescription.setProjectProspect(initialiseProjectProspect(projectDescription.getId(), projectDescriptionV2DTO));
        }

        savedProjectDescription.setRelProjectRelatedIndividual(computeRelProjectRelatedIndividuals(projectDescription.getId(), projectScopeIntlId, projectDescriptionV2DTO.getInitiatorContacts()));

        ProjectDescription finalSave = projectDescriptionsRepository.save(savedProjectDescription);

        return projectDescriptionMapperV2.toDTO(finalSave);
    }

    private FundDTO createOrFetchFund(ProjectDescriptionV2DTO projectDescriptionV2DTO) {
        return Optional.ofNullable(projectDescriptionV2DTO.getFund().getFundId())
                .map(fundId -> fundService.getFund(Integer.valueOf(fundId)))
                .or(() -> Optional.ofNullable(projectDescriptionV2DTO.getFund().getLegalName())
                        .map(legalName -> fundService.createFund(new FundDTO().legalName(legalName).regulatedAs(Collections.emptyList()).supervisoryAuthorities(Collections.emptyList()), LocalDateTime.now()))
                ).orElseThrow(() -> new BadRequestException("Fund id or fund legal name must not be null."));
    }

    private ProjectInitiator initialiseProjectInitiator(Integer projectDescriptionId, ProjectDescriptionV2DTO projectDescriptionV2DTO) {
        ProjectInitiator projectInitiator = new ProjectInitiator();
        LocalDateTime now = LocalDateTime.now();

        Integer initiatorCompanyId = Integer.valueOf(projectDescriptionV2DTO.getInitiatorCompany().getId());

        projectInitiator.setId(projectDescriptionId);
        projectInitiator.setLegalPersonId(initiatorCompanyId);
        projectInitiator.setLegalPerson(legalPersonService.getLegalPersonInternal(initiatorCompanyId));
        projectInitiator.setConvAMAcceptanceStatusUnderAssessmentStartDate(now);
        projectInitiator.setPbsAcceptanceStatusUnderAssessmentStartDate(now);
        projectInitiator.setConvAMAcceptanceStatusTypes(typeMapper.mapToConvAMAcceptanceStatusType(typeService.getAllConvAMAcceptanceStatusType()));
        projectInitiator.setPbsAcceptanceStatusTypes(typeMapper.mapToPBSAcceptanceStatusType(typeService.getAllPBSAcceptanceStatusType()));
        projectInitiator.setExpectedGrossRevenue(projectDescriptionV2DTO.getExpectedGrossRevenue());

        return projectInitiator;
    }

    private ProjectProspect initialiseProjectProspect(Integer projectDescriptionId, ProjectDescriptionV2DTO projectDescriptionDTO) {
        ProjectProspect projectProspect = new ProjectProspect();
        LocalDateTime now = LocalDateTime.now();

        projectProspect.setId(projectDescriptionId);
        projectProspect.setPbsAcceptanceStatusUnderAssessmentStartDate(now);
        projectProspect.setPbsAcceptanceStatusTypes(typeMapper.mapToPBSAcceptanceStatusType(typeService.getAllPBSAcceptanceStatusType()));

        projectProspect.setLegalPersonId(Integer.valueOf(projectDescriptionDTO.getProspectCompany().getId()));
        projectProspect.setLegalPerson(legalPersonService.getLegalPersonInternal(Integer.valueOf(projectDescriptionDTO.getProspectCompany().getId())));
        projectProspect.setContactPersonName(projectDescriptionDTO.getProspectContactPerson());
        projectProspect.setExpectedGrossRevenue(projectDescriptionDTO.getExpectedGrossRevenue());
        Optional.ofNullable(projectDescriptionDTO.getBusinessUnit())
                .map(BusinessUnitEnumDTO::getValue)
                .ifPresent(buValue ->
                        businessUnitTypeRepository.findByIntlId(buValue).ifPresentOrElse(bu -> {
                            projectProspect.setBusinessUnitTypeId(bu.getId());
                            projectProspect.setBusinessUnit(bu);
                        }, () -> {
                            throw new ResourceNotFoundException("Business unit " + projectDescriptionDTO.getBusinessUnit() + " not found."
                            );
                        }));

        return projectProspect;
    }

    private List<RelProjectRelatedIndividual> computeRelProjectRelatedIndividuals(Integer projectId, String projectScopeIntlId, List<NaturalPersonDTO> initiatorContacts) {
        if (CollectionUtils.isNotEmpty(initiatorContacts)) {
            ProjectRelatedIndividualType projectInitiatorContactPerson = projectRelatedIndividualTypeRepository.findByIntlId(PROJECT_INITIATOR_CONTACT_PERSON).orElse(null);
            ProjectRelatedIndividualType prospectContactPerson = projectRelatedIndividualTypeRepository.findByIntlId(PROSPECT_CONTACT_PERSON).orElse(null);

            return initiatorContacts.stream().map(initiatorContact -> {
                RelProjectRelatedIndividual rel = new RelProjectRelatedIndividual();
                rel.setNaturalPersonId(Integer.valueOf(initiatorContact.getId()));
                rel.setNaturalPerson(naturalPersonService.getNaturalPersonByIdInternal(Integer.valueOf(initiatorContact.getId())));
                rel.setProjectId(projectId);

                if (ProjectScopeIdDTO.FUND.getValue().equals(projectScopeIntlId)) { // TODO: confirmer avec robin cette règle
                    rel.setProjectRelatedIndividualType(projectInitiatorContactPerson);
                } else if (ProjectScopeIdDTO.IIS.getValue().equals(projectScopeIntlId) || ProjectScopeIdDTO.ICS.getValue().equals(projectScopeIntlId)) {
                    rel.setProjectRelatedIndividualType(prospectContactPerson);
                }
                return rel;
            }).collect(Collectors.toList());
        }
        return null;
    }
}