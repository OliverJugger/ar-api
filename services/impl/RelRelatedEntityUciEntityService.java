package com.bdl.epbs_fund_api.services.impl;

import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_REL_ENT_CREATE;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_REL_ENT_DEACTIVATE;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_REL_ENT_DELETE;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_REL_ENT_UPDATE;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Stream;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.BooleanUtils;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.history.Revision;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bdl.epbs_fund_api.authentication.UserContext;
import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.enums.RoutineExecutionOriginEnum;
import com.bdl.epbs_fund_api.mappings.RelRelatedEntityMapper;
import com.bdl.epbs_fund_api.mappings.RevisionMapper;
import com.bdl.epbs_fund_api.mappings.audit.RelRelatedEntityAuditMapper;
import com.bdl.epbs_fund_api.model.AbstractTypeDTO;
import com.bdl.epbs_fund_api.model.RelRelatedEntityDTO;
import com.bdl.epbs_fund_api.model.RelUCIEntityStatusTypeDTO;
import com.bdl.epbs_fund_api.model.SegmentDTO;
import com.bdl.epbs_fund_api.model.SubFundDTO;
import com.bdl.epbs_fund_api.model.UCIStatusEnumDTO;
import com.bdl.epbs_fund_api.model.relations.RelRelatedEntity;
import com.bdl.epbs_fund_api.model.relations.RelUCILegalPerson;
import com.bdl.epbs_fund_api.model.types.RelatedEntityType;
import com.bdl.epbs_fund_api.repositories.RelRelatedEntityRepository;
import com.bdl.epbs_fund_api.repositories.type.RelatedEntityTypeRepository;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.services.access.HasAccess;
import com.bdl.epbs_fund_api.services.audit.EntityLinkedToTaskAuditService;
import com.bdl.epbs_fund_api.services.audit.RelRelatedEntityAuditDTO;
import com.bdl.epbs_fund_api.services.audit.RevisionDTO;
import com.bdl.epbs_fund_api.services.audit.RevisionDiffItemDTO;
import com.bdl.epbs_fund_api.services.audit.RevisionMetadataDTO;
import com.bdl.epbs_fund_api.specification.RelRelatedEntitySpecification;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedEntitySearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.rel_related_entity.RelRelatedEntityRule;
import com.bdl.epbs_fund_api.utils.UCIEntityUtils;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class RelRelatedEntityUciEntityService extends EntityLinkedToTaskAuditService<RelRelatedEntityRepository, RelRelatedEntity, RelRelatedEntityAuditDTO> {

	private final SubFundService subFundService;
    private final UCIEntityService uCIEntityService;
    private final RelUCILegalPersonService relUCILegalPersonService;

    private final RelRelatedEntityAuditMapper relRelatedEntityAuditMapper;
    private final RevisionMapper<RelRelatedEntityAuditDTO> revisionMapper;
    private final RelRelatedEntityMapper relRelatedEntityMapper;
    private final TechnicalAccessService technicalAccessService;

    private final List<RelRelatedEntityRule> relRelatedEntityRules;
    private final RelRelatedEntityRepository relRelatedEntityRepository;
    private final RelatedEntityTypeRepository relatedEntityTypeRepository;

    public RelRelatedEntityUciEntityService(
    							   SubFundService subFundService,
                                   RelRelatedEntityRepository repository,
                                   RelatedEntityTypeRepository relatedEntityTypeRepository,
                                   TechnicalAccessService technicalAccessService,
                                   RelRelatedEntityRepository relRelatedEntityRepository,
                                   List<RelRelatedEntityRule> relRelatedEntityRules,
                                   UCIEntityService uCIEntityService,
                                   RelUCILegalPersonService relUCILegalPersonService,
                                   RelRelatedEntityMapper relRelatedEntityMapper,
                                   RelRelatedEntityAuditMapper relRelatedEntityAuditMapper,
                                   RevisionMapper<RelRelatedEntityAuditDTO> revisionMapper) {
        super(repository);
        this.subFundService = subFundService;
        this.technicalAccessService = technicalAccessService;
        this.relRelatedEntityRepository = relRelatedEntityRepository;
        this.relatedEntityTypeRepository = relatedEntityTypeRepository;
        this.relRelatedEntityRules = relRelatedEntityRules;
        this.uCIEntityService = uCIEntityService;
        this.relUCILegalPersonService = relUCILegalPersonService;
        this.relRelatedEntityAuditMapper = relRelatedEntityAuditMapper;
        this.revisionMapper = revisionMapper;
        this.relRelatedEntityMapper = relRelatedEntityMapper;
    }
    
	public List<RelRelatedEntityDTO> getAllFundRelatedEntities(Integer fundId, boolean activeOnly) {
        return getAllRelatedEntitiesDTOByUciEntityIds(List.of(fundId), activeOnly);
	}
	
	@Transactional
	public List<RelRelatedEntityDTO> getAllSubFundRelatedEntities(Integer fundId, boolean activeOnly) {
		
		List<SubFundDTO> subFunds = Optional.ofNullable(subFundService.findByFundId(fundId))
					.orElse(Collections.emptyList());
		
		Stream<Integer> uciEntityIds = Stream.concat(
			subFunds
				.stream()
				.map(SubFundDTO::getId)
				.map(Integer::valueOf),
			subFunds
				.stream()
				.map(SubFundDTO::getSegments)
				.flatMap(List::stream)
				.map(SegmentDTO::getId)
				.map(Integer::valueOf));
		
        return getAllRelatedEntitiesDTOByUciEntityIds(uciEntityIds.toList(), activeOnly);
	}

    public RelRelatedEntity getRelRelatedEntityById(Integer relatedEntityId) {
        return repository.findById(relatedEntityId).orElse(null);
    }
    
    public List<RelRelatedEntityDTO> getAllRelatedEntitiesDTOByUciEntityIds(List<Integer> uciEntityId, Boolean activeOnly) {
        return relRelatedEntityMapper.toDTO(getAllRelRelatedEntities(uciEntityId, null, null, activeOnly));
    }

    public List<RelRelatedEntity> getAllRelRelatedEntities(List<Integer> uciEntityIds, Boolean activeOnly) {
        return getAllRelRelatedEntities(uciEntityIds, null, null, activeOnly);
    }

    public List<RelRelatedEntity> getAllRelRelatedEntities(List<Integer> uciEntityIds, Integer legalPersonId, UUID taskUid, Boolean activeOnly) {
        List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();

        RelRelatedEntitySearchCriteria relRelatedEntitySearchCriteria = RelRelatedEntitySearchCriteria.builder()
                .dataProfileIntlIds(dataProfilesUserIntlId)
                .uciEntityIds(uciEntityIds)
                .legalPersonId(legalPersonId)
                .taskUid(taskUid)
                .build();

        List<RelRelatedEntity> relatedEntities = relRelatedEntityRepository.findAll(new RelRelatedEntitySpecification(relRelatedEntitySearchCriteria, relRelatedEntityRules));
        
        return BooleanUtils.isTrue(activeOnly)
                ? relatedEntities.stream()
                .filter(this::isActive)
                .toList()
                : relatedEntities;
    }

    @HasAccess(EPBS_ROLE_REL_ENT_CREATE)
    @Transactional
    public RelRelatedEntity createRelRelatedEntity(RelRelatedEntity relRelatedEntity) {
    	
        relRelatedEntity.setTecUser(UserContext.getCurrentUser());

        RelUCILegalPerson relUciLegalPerson = relUCILegalPersonService.findOrCreateByLegalPersonIdAndUciEntityId(
                relRelatedEntity.getRelUciLegalPerson().getLegalPerson(),
                relRelatedEntity.getRelUciLegalPerson().getUciEntity());
        RelatedEntityType relRelatedEntityType = relatedEntityTypeRepository.findById(relRelatedEntity.getRelatedEntityType().getId()).orElseThrow(() -> new ResourceNotFoundException("related entity type not found"));
    	Integer uciEntityId = relRelatedEntity.getRelUciLegalPerson().getUciEntity().getId();
        String uciEntityTypeIntlId = relRelatedEntity.getRelUciLegalPerson().getUciEntity().getType().getIntlId();

        relRelatedEntity.setRelUciLegalPerson(relUciLegalPerson);
        relRelatedEntity.setRelatedEntityType(relRelatedEntityType);

        RelRelatedEntity savedRelUciLegalPerson = repository.save(relRelatedEntity);

        technicalAccessService.updateTechnicalTables(savedRelUciLegalPerson.getId(), Constants.INTL_ID_ELEM_REL_ENT);

        return savedRelUciLegalPerson;
    }

    @HasAccess(EPBS_ROLE_REL_ENT_UPDATE)
    @Transactional
    public RelRelatedEntity updateRelRelatedEntity(RelRelatedEntity relRelatedEntity) {
    	relRelatedEntity.setTecUser(UserContext.getCurrentUser());
		
		RelUCILegalPerson relUciLegalPerson = relUCILegalPersonService.findOrCreateByLegalPersonIdAndUciEntityId(
		        relRelatedEntity.getRelUciLegalPerson().getLegalPerson(),
		        relRelatedEntity.getRelUciLegalPerson().getUciEntity());
		RelatedEntityType relRelatedEntityType = relatedEntityTypeRepository.findById(relRelatedEntity.getRelatedEntityType().getId()).orElseThrow(() -> new ResourceNotFoundException("related entity type not found"));
    	Integer uciEntityId = relRelatedEntity.getRelUciLegalPerson().getUciEntity().getId();
        String uciEntityTypeIntlId = relRelatedEntity.getRelUciLegalPerson().getUciEntity().getType().getIntlId();
        
		relRelatedEntity.getRelUciLegalPerson().setId(relUciLegalPerson.getId());
		relRelatedEntity.setRelatedEntityType(relRelatedEntityType);
		
		RelRelatedEntity savedRelUciLegalPerson = repository.save(relRelatedEntity);

        return savedRelUciLegalPerson;
    }


    @HasAccess(EPBS_ROLE_REL_ENT_DEACTIVATE)
    @Transactional
    public RelRelatedEntity updateRelRelatedEntityInactivate(Integer relRelatedEntityId, LocalDate endDate) {
    	
    	RelRelatedEntity relatedEntitySaved = repository.findById(relRelatedEntityId)
    			.map(re -> {
    			    re.setValidTo(endDate);
    			    repository.save(re);
    			    return re;
    			})
    			.orElse(null);
    	
    	Integer uciEntityId = relatedEntitySaved.getRelUciLegalPerson().getUciEntity().getId();
        String uciEntityTypeIntlId = relatedEntitySaved.getRelUciLegalPerson().getUciEntity().getType().getIntlId();

        return relatedEntitySaved;
    }

    @HasAccess(EPBS_ROLE_REL_ENT_DELETE)
    public void deleteRelRelatedEntity(Integer relRelatedEntityId) {
        repository.findById(relRelatedEntityId)
                .ifPresent(re -> {
                	Integer uciEntityId = re.getRelUciLegalPerson().getUciEntity().getId();
                    String uciEntityTypeIntlId = re.getRelUciLegalPerson().getUciEntity().getType().getIntlId();
                    repository.deleteById(relRelatedEntityId);
                });
    }

    @Transactional
    public RelRelatedEntity updateRelRelatedEntityUnlinkTask(Integer relRelatedEntityId) {
        log.info("updateRelRelatedEntityUnlinkTask");
        repository.unlinkTask(relRelatedEntityId);
        return repository.findById(relRelatedEntityId).orElse(null);
    }

    @Transactional
    public RelRelatedEntity updateRelRelatedEntityLinkTask(Integer relRelatedEntityId, UUID taskUid) {
        log.info("updateRelRelatedEntityLinkTask");
        repository.linkTask(relRelatedEntityId, taskUid.toString());
        return repository.findById(relRelatedEntityId).orElse(null);
    }

    public List<RevisionDTO> getRelRelatedEntityRevisionsById(Integer id) {
        List<RevisionDTO<RelRelatedEntityAuditDTO>> revisionsByUUid = getRevisionsByUUid(id);
        return revisionMapper.map(revisionsByUUid);
    }

    public List<RevisionDiffItemDTO> getRelRelatedEntityRevisionsDiff(Integer id, List<Integer> revisionIds) {
        List<RevisionDiffItemDTO> result = null;
        if (!CollectionUtils.isEmpty(revisionIds)) {
            List<Integer> revisionsInt = revisionIds
                    .stream()
                    .map(r -> new BigDecimal(r).intValue())
                    .toList();
            result = getRevisionsDiff(id, revisionsInt);
        }
        return result;
    }

    public List<RevisionDiffItemDTO> getRelRelatedEntityRevisionDiffByTaskUuid(Integer id, UUID taskUuid) {
        return getRevisionsDiff(id, taskUuid.toString());
    }

    @Override
    protected RevisionDTO<RelRelatedEntityAuditDTO> getRevisionDtoInstance() {
        final RevisionDTO<RelRelatedEntityAuditDTO> revisionDTO = new RevisionDTO<>();
        revisionDTO.setEntity(new RelRelatedEntityAuditDTO());
        revisionDTO.setMetadata(new RevisionMetadataDTO());
        return revisionDTO;
    }

    @Override
    protected void mapChild(RevisionDTO<RelRelatedEntityAuditDTO> revisionDto,
                            Revision<Integer, RelRelatedEntity> revision) {
        revisionDto.setEntity(relRelatedEntityAuditMapper.toRelRelatedEntityAuditDTO(revision.getEntity()));
    }

    private boolean isActive(RelRelatedEntity relatedEntity) {
        int uciEntityId = relatedEntity.getRelUciLegalPerson().getUciEntity().getId();
        boolean hasActiveTask = relatedEntity.getTaskUid() != null;
        LocalDate now = LocalDate.now();

        return Optional.ofNullable(relatedEntity.getValidTo())
                .map(validTo ->
                        (validTo.isAfter(now) || (validTo.equals(now) && hasActiveTask))
                        && !UCIEntityUtils.UCI_CLOSE_STATUS.contains(getCurrentUciStatusToString(uciEntityId)))
                .orElseGet(() -> !UCIEntityUtils.UCI_CLOSE_STATUS.contains(getCurrentUciStatusToString(uciEntityId)));
    }

    private String getCurrentUciStatusToString(int uciEntityId) {
        return Optional.ofNullable(uCIEntityService.getCurrentStatus(uciEntityId))
                .map(RelUCIEntityStatusTypeDTO::getStatusType)
                .map(AbstractTypeDTO::getIntlId)
                .orElse(UCIStatusEnumDTO.NOT_AVAILABLE.getValue());
    }
}
