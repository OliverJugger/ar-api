package com.bdl.epbs_fund_api.services.impl;

import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_FULL_ACCESS;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_SUBFUND_CREATE;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_SUBFUND_UPDATE_STATIC_DATA;

import java.math.BigDecimal;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.function.IntFunction;

import com.bdl.epbs_fund_api.model.*;
import org.apache.commons.collections4.CollectionUtils;
import org.springframework.boot.actuate.endpoint.InvalidEndpointRequestException;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.history.Revision;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.authentication.UserContext;
import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.mappings.RevisionMapper;
import com.bdl.epbs_fund_api.mappings.SubFundMapper;
import com.bdl.epbs_fund_api.mappings.audit.SubFundAuditMapper;
import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.repositories.SubFundRepository;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.services.access.HasAccess;
import com.bdl.epbs_fund_api.services.audit.EntityLinkedToTaskAuditService;
import com.bdl.epbs_fund_api.services.audit.RevisionDTO;
import com.bdl.epbs_fund_api.services.audit.RevisionDiffItemDTO;
import com.bdl.epbs_fund_api.services.audit.RevisionMetadataDTO;
import com.bdl.epbs_fund_api.services.audit.SubFundDTOAudit;
import com.bdl.epbs_fund_api.specification.SubFundSpecification;
import com.bdl.epbs_fund_api.specification.criteria.SubFundSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.sub_fund.SubFundRule;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import jakarta.transaction.Transactional;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class SubFundService extends EntityLinkedToTaskAuditService<SubFundRepository, SubFund, SubFundDTOAudit> {

    private final UCIEntityService uciEntityService;

    private final SegmentService segmentService;

    private final ShareClassService shareClassService;

    private final RelRelatedIndividualService relRelatedIndividualService;

    private final RelRelatedEntityUciEntityService relRelatedEntityUciEntityService;

    private final SubFundMapper subFundMapper;

    private final SubFundAuditMapper subFundAuditMapper;

    private final List<SubFundRule> subFundRules;

    private final RevisionMapper<SubFundDTOAudit> revisionMapper;

    private final TechnicalAccessService technicalAccessService;

    private final IntFunction<ResourceNotFoundException> notFoundException = id -> new ResourceNotFoundException(String.format("Subfund with id %s could not be found", id));

    public SubFundService(SubFundRepository repository,
                          UCIEntityService uciEntityService,
                          SegmentService segmentService,
                          ShareClassService shareClassService,
                          RelRelatedIndividualService relRelatedIndividualService,
                          @Lazy RelRelatedEntityUciEntityService relRelatedEntityUciEntityService,
                          SubFundMapper subFundMapper,
                          SubFundAuditMapper subFundAuditMapper,
                          List<SubFundRule> subFundRules,
                          RevisionMapper<SubFundDTOAudit> revisionMapper,
                          TechnicalAccessService technicalAccessService) {
        super(repository);
        this.uciEntityService = uciEntityService;
        this.segmentService = segmentService;
        this.shareClassService = shareClassService;
        this.relRelatedIndividualService = relRelatedIndividualService;
        this.relRelatedEntityUciEntityService = relRelatedEntityUciEntityService;
        this.subFundMapper = subFundMapper;
        this.subFundAuditMapper = subFundAuditMapper;
        this.subFundRules = subFundRules;
        this.revisionMapper = revisionMapper;
        this.technicalAccessService = technicalAccessService;
    }

    public List<SubFundDTO> getAllSubFunds(String nameContains, Integer fundId, Integer limit) {
        log.debug("SubFundService::getAllSubFunds");

        if (!(nameContains == null && fundId == null)) {

            List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();
            SubFundSearchCriteria subFundSearchCriteria = SubFundSearchCriteria.builder()
                    .fundId(fundId)
                    .name(Optional.ofNullable(nameContains)
                            .map(val -> URLDecoder.decode(val, StandardCharsets.UTF_8))
                            .map(String::trim)
                            .orElse(null))
                    .dataProfileIntlIds(dataProfilesUserIntlId)
                    .build();

            List<SubFund> subFunds = repository.findAll(new SubFundSpecification(subFundSearchCriteria, subFundRules));
            List<SubFundDTO> subFundsDTOs = subFundMapper.toDTO(subFunds);
            subFundsDTOs = addUCIStatusToSubFundAndFund(subFundsDTOs);
            return subFundsDTOs;
        }

        return Collections.emptyList();
    }

    @HasAccess(EPBS_ROLE_FULL_ACCESS)
    public List<SubFundDTO> getAllSubFunds() {
        return subFundMapper.toDTO(repository.findAll(PageRequest.of(0, 100)).getContent());
    }

    @Deprecated(forRemoval = true, since = "12/02/2025")
    public SubFundDTO getSubFundById(Integer id) {
        Optional<SubFund> subFund = repository.findById(id);
        return subFund.map(subFundMapper::toDTO).orElse(null);
    }

    public SubFund getSubFundEntity(Integer id) {
        return repository.findById(id).orElseThrow(() -> notFoundException.apply(id));
    }

    public SubFund getSubFundByIdInternal(Integer id) {
        return repository.findById(id).orElseThrow(() -> notFoundException.apply(id));
    }

    public SubFund getSubFundBySegmentIdInternal(Integer segmentId) {
        return repository.findBySegmentId(segmentId).orElseThrow(() -> notFoundException.apply(segmentId));
    }

    public SubFundDTO getSubFundBySegmentId(Integer segmentId) {
        Optional<SubFund> subFund = repository.findBySegmentId(segmentId);
        return subFund.map(subFundMapper::toDTO).orElse(null);
    }

    public List<SegmentDTO> getAllSegmentsActiveBySubFundId(Integer subFundId) {
        return segmentService.findAllActiveBySubFundId(subFundId);
    }

    public List<ShareClassDTO> getAllShareClassesActiveBySubFundId(Integer shareClassId) {
        return shareClassService.findAllBySubFundId(shareClassId);
    }

    public HasActiveRelationDTO hasActiveRelatedEntity(Integer subFundId) {
        HasActiveRelationDTO hasActiveRelatedEntity = new HasActiveRelationDTO();
        hasActiveRelatedEntity.setId(subFundId);
        hasActiveRelatedEntity.setValue(CollectionUtils.isNotEmpty(relRelatedEntityUciEntityService.getAllRelRelatedEntities(List.of(subFundId), true)));
        return hasActiveRelatedEntity;
    }

    public HasActiveRelationDTO hasActiveRelatedIndividual(Integer subFundId) {
        HasActiveRelationDTO hasActiveRelatedIndividual = new HasActiveRelationDTO();
        hasActiveRelatedIndividual.setId(subFundId);
        hasActiveRelatedIndividual.setValue(relRelatedIndividualService.hasActiveRelatedIndividualSubFund(subFundId));
        return hasActiveRelatedIndividual;
    }

    public List<RevisionDTO> getSubFundRevisionsById(Integer id) {
        List<RevisionDTO<SubFundDTOAudit>> revisionsByUUid = getRevisionsByUUid(id);
        return revisionMapper.map(revisionsByUUid);
    }

    public List<RevisionDiffItemDTO> getSubFundRevisionsDiff(Integer id, List<Long> revisionIds) {
        List<RevisionDiffItemDTO> result = null;
        if(!CollectionUtils.isEmpty(revisionIds)) {
            List<Integer> revisionsInt = revisionIds
                    .stream()
                    .map(r -> new BigDecimal(r).intValue())
                    .toList();
            result = getRevisionsDiff(id, revisionsInt);
        }
        return result;
    }

    public List<RevisionDiffItemDTO> getSubFundRevisionsDiffByTaskUuid(Integer id, UUID taskUuid) {
        return getRevisionsDiff(id, taskUuid.toString());
    }

    @HasAccess(EPBS_ROLE_SUBFUND_CREATE)
    @Transactional
    public SubFundDTO createSubFund(SubFundDTO subFundDTO) {
        // Create UCI Entity
        UCIEntity uciEntity = uciEntityService.createUCIEntity(Constants.INTL_ID_UCIENTITY_SUB_FUND, LocalDateTime.now(), UCIStatusEnumDTO.PROSPECT.getValue());

        subFundDTO.setId(String.valueOf(uciEntity.getId()));

        SubFund subFund = subFundMapper.toEntity(subFundDTO);
        subFund.setTecUser(UserContext.getCurrentUser());
        subFund = repository.save(subFund);

        technicalAccessService.updateTechnicalTables(subFund.getId(), Constants.INTL_ID_ELEM_SUBFUND);

        SubFundDTO result = subFundMapper.toDTO(subFund);

        return result;
    }

    @Deprecated(since= "01/03/2025") // use V2
    @HasAccess(EPBS_ROLE_SUBFUND_UPDATE_STATIC_DATA)
    @Transactional
    public SubFundDTO updateSubFund(Integer subFundId, SubFundDTO subFundDTO) {
        SubFund initialSubFund = repository.findById(Integer.parseInt(subFundDTO.getId())).get();
        SubFund subFund = subFundMapper.toEntity(subFundDTO);

        subFund.setJiraDepCtrlRef(initialSubFund.getJiraDepCtrlRef());
        // SubFund is a child of UCIEntity so it needs his ID and be linked with RelUCIStatusTypes
        List<RelUCIEntityStatusTypeDTO> relUCIEntityStatusTypeDTOS = Optional.ofNullable(subFundDTO.getUciEntity())
                .map(UCIEntityDTO::getRelUciStatusTypes)
                .orElse(new ArrayList<>());
        UCIEntity uciEntity = Optional.ofNullable(
                        uciEntityService.updateUCIEntityAndRelStatusType(subFundId, relUCIEntityStatusTypeDTOS))
                .orElseThrow(() -> new InvalidEndpointRequestException("Wrong ID", "ID " + subFundId + "does not exist for UCIEntity"));

        subFundDTO.setId(String.valueOf(uciEntity.getId()));

        subFund.setTecUser(UserContext.getCurrentUser());
        subFund.setUciEntity(uciEntity);
        subFund = repository.save(subFund);
        SubFundDTO result = subFundMapper.toDTO(subFund);

        return result;
    }

    public SubFundDTO updateAfterCreationInJira(SubFundDTO inputDTO) {
        log.debug("SubFundService::updateAfterCreationInJira");

        SubFund subFundToUpdate = subFundMapper.toEntity(inputDTO);

        if (subFundToUpdate != null && subFundToUpdate.getId() != null) {
            subFundToUpdate.setTecUser(UserContext.getCurrentUser());
            return subFundMapper.toDTO(repository.save(subFundToUpdate));
        }
        return null;
    }

    @Transactional
    public SubFundDTO updateSubFundLinkTask(Integer id, UUID taskUid) {
        repository.linkTask(id, taskUid.toString());
        return 	repository.findById(id)
                .map(subFundMapper::toDTO)
                .orElse(null);
    }

    @Transactional
    public SubFundDTO updateSubFundUnlinkTask(Integer id) {
        repository.unlinkTask(id);
        return 	repository.findById(id)
                .map(subFundMapper::toDTO)
                .orElse(null);
    }

    public List<SubFundDTO> findByRelationFOrSFId(Integer relRelatedEntityId) {
        log.debug(String.format("SubFundService::findByRelationFOrSFId %s", relRelatedEntityId.toString()));

        List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();
        if (!dataProfilesUserIntlId.isEmpty()) {
            return subFundMapper.toDTO(
                    repository.findByRelationFOrSFId(relRelatedEntityId, dataProfilesUserIntlId));
        }
        return Collections.emptyList();
    }

    public List<SubFundDTO> findByFundId(Integer id) {
        return getAllSubFunds(null, id, 1000);
    }

    public List<SegmentDTO> findAllSegmentActiveBySubFundId(String subFundId) {
        return segmentService.findAllActiveBySubFundId(Integer.parseInt(subFundId));
    }

    @Override
    protected RevisionDTO<SubFundDTOAudit> getRevisionDtoInstance() {
        final RevisionDTO<SubFundDTOAudit> revisionDTO = new RevisionDTO<>();
        revisionDTO.setEntity(new SubFundDTOAudit());
        revisionDTO.setMetadata(new RevisionMetadataDTO());
        return revisionDTO;
    }

    @Override
    protected void mapChild(RevisionDTO<SubFundDTOAudit> revisionDto, Revision<Integer, SubFund> revision) {
        revisionDto.setEntity(subFundAuditMapper.toSubFundDTOAudit(revision.getEntity()));
    }

    private List<SubFundDTO> addUCIStatusToSubFundAndFund(List<SubFundDTO> subFunds) {
        subFunds = subFunds.stream()
                .map(this::addUCIStatusToSubFundAndFund)
                .toList();
        return subFunds;
    }

    private SubFundDTO addUCIStatusToSubFundAndFund(SubFundDTO subFund) {
        log.info(String.format("addUCIStatusToSubFundAndFund for subFund %s", subFund.getId()));
        List<RelUCIEntityStatusTypeDTO> currentSubFundRelUCIStatus = List.of(uciEntityService.getCurrentStatus(Integer.valueOf(subFund.getId())));
        subFund.setRelUciStatusTypes(currentSubFundRelUCIStatus);

        List<RelUCIEntityStatusTypeDTO> currentFundRelUCIStatus = List.of(uciEntityService.getCurrentStatus(Integer.valueOf(subFund.getFund().getFundId())));
        subFund.getFund().setRelUciStatusTypes(currentFundRelUCIStatus);
        return subFund;
    }

}
