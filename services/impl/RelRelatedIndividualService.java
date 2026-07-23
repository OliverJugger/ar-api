package com.bdl.epbs_fund_api.services.impl;

import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_REL_IND_CREATE;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_REL_IND_DEACTIVATE;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_REL_IND_DELETE;
import static com.bdl.epbs_fund_api.constants.Constants.EPBS_ROLE_REL_IND_UPDATE;
import static com.bdl.epbs_fund_api.constants.Constants.INTL_ID_ELEM_REL_IND;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

import com.bdl.epbs_fund_api.model.relations.RelLegalPersonNaturalPerson;
import com.bdl.epbs_fund_api.model.relations.RelLegalPersonRelatedIndividual;
import com.bdl.epbs_fund_api.model.relations.RelUCINaturalPerson;
import com.bdl.epbs_fund_api.model.relations.RelUCIRelatedIndividual;
import com.bdl.utils.exceptions.BadRequestException;
import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.history.Revision;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bdl.epbs_fund_api.authentication.UserContext;
import com.bdl.epbs_fund_api.mappings.RelRelatedIndividualMapper;
import com.bdl.epbs_fund_api.mappings.RevisionMapper;
import com.bdl.epbs_fund_api.mappings.audit.RelatedIndividualAuditMapper;
import com.bdl.epbs_fund_api.model.RelRelatedIndividualDTO;
import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.repositories.RelRelatedIndividualRepository;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.services.access.HasAccess;
import com.bdl.epbs_fund_api.services.audit.EntityLinkedToTaskAuditService;
import com.bdl.epbs_fund_api.services.audit.RelatedIndividualDTOAudit;
import com.bdl.epbs_fund_api.services.audit.RevisionDTO;
import com.bdl.epbs_fund_api.services.audit.RevisionDiffItemDTO;
import com.bdl.epbs_fund_api.services.audit.RevisionMetadataDTO;
import com.bdl.epbs_fund_api.specification.RelRelatedIndividualSpecification;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.rel_related_individual.RelRelatedIndividualRule;
import com.bdl.utils.exceptions.ResourceNotFoundException;

@Deprecated(forRemoval = true, since = "25/03/2025")
@Service
public class RelRelatedIndividualService extends EntityLinkedToTaskAuditService<RelRelatedIndividualRepository, RelRelatedIndividual, RelatedIndividualDTOAudit> {

    private final TechnicalAccessService technicalAccessService;

    private final RelatedIndividualAuditMapper relatedIndividualAuditMapper;
    private final RelRelatedIndividualMapper relRelatedIndividualMapper;

    private final List<RelRelatedIndividualRule> relRelatedIndividualRules;
    private final RelRelatedIndividualRepository relRelatedIndividualRepository;

    private final RevisionMapper<RelatedIndividualDTOAudit> revisionMapper;
    private final RelUCINaturalPersonService relUCINaturalPersonService;
    private final RelLegalPersonNaturalPersonService relLegalPersonNaturalPersonService;
    private final RelUCIRelatedIndividualService relUCIRelatedIndividualService;
    private final RelLegalPersonRelatedIndividualService relLegalPersonRelatedIndividualService;

    @Autowired
    public RelRelatedIndividualService(RelRelatedIndividualRepository relRelatedIndividualRepository,
                                       List<RelRelatedIndividualRule> relRelatedIndividualRules,
                                       RelRelatedIndividualMapper relRelatedIndividualMapper,
                                       TechnicalAccessService technicalAccessService,
                                       RelatedIndividualAuditMapper relatedIndividualAuditMapper,
                                       RevisionMapper<RelatedIndividualDTOAudit> revisionMapper,
                                       RelLegalPersonNaturalPersonService relLegalPersonNaturalPersonService,
                                       RelUCINaturalPersonService relUCINaturalPersonService,
                                       RelUCIRelatedIndividualService relUCIRelatedIndividualService,
                                       RelLegalPersonRelatedIndividualService relLegalPersonRelatedIndividualService) {
        super(relRelatedIndividualRepository);
        this.relRelatedIndividualRepository = relRelatedIndividualRepository;
        this.relRelatedIndividualRules = relRelatedIndividualRules;
        this.relRelatedIndividualMapper = relRelatedIndividualMapper;
        this.technicalAccessService = technicalAccessService;
        this.relatedIndividualAuditMapper = relatedIndividualAuditMapper;
        this.revisionMapper = revisionMapper;
        this.relUCINaturalPersonService = relUCINaturalPersonService;
        this.relLegalPersonNaturalPersonService = relLegalPersonNaturalPersonService;
        this.relUCIRelatedIndividualService = relUCIRelatedIndividualService;
        this.relLegalPersonRelatedIndividualService = relLegalPersonRelatedIndividualService;
    }

    @HasAccess(EPBS_ROLE_REL_IND_CREATE)
    @Transactional
    public RelRelatedIndividualDTO createRelatedIndividual(RelRelatedIndividualDTO relRelatedIndividualDTO) {
        RelRelatedIndividual relRelatedIndividual =  relRelatedIndividualMapper.toEntity(relRelatedIndividualDTO);
        relRelatedIndividual.setTecUser(UserContext.getCurrentUser());

        if (Objects.nonNull(relRelatedIndividualDTO.getLegalPerson())) {
            RelLegalPersonNaturalPerson relLegalPersonNaturalPerson = relLegalPersonNaturalPersonService.createRelLegalPersonNaturalPersonFromRelRelatedIndividualDTO(relRelatedIndividualDTO);
            RelLegalPersonRelatedIndividual relLegalPersonRelatedIndividual = new RelLegalPersonRelatedIndividual();
            relLegalPersonRelatedIndividual.setRelLegalPersonNaturalPerson(relLegalPersonNaturalPerson);
            // We must save now to generate the ID that will be put in RelLegalPersonRelatedIndividual
            // PK (which is used as a FK). The model should be changed so that the PK is no longer used as a FK and
            // a FK table pointing to the RelLegalPersonNaturalPerson table is added
            relRelatedIndividual = relRelatedIndividualRepository.save(relRelatedIndividual);
            relLegalPersonRelatedIndividual.setId(relRelatedIndividual.getId());
            relRelatedIndividual.setRelLegalPersonRelatedIndividual(relLegalPersonRelatedIndividual);
        }
        else if (Objects.nonNull(relRelatedIndividualDTO.getFund()) || Objects.nonNull(relRelatedIndividualDTO.getSubFund())) {
            RelUCINaturalPerson relUCINaturalPerson = relUCINaturalPersonService.createRelUCINaturalPersonFromRelRelatedIndividualDTO(relRelatedIndividualDTO);
            RelUCIRelatedIndividual relUCIRelatedIndividual = new RelUCIRelatedIndividual();
            relUCIRelatedIndividual.setRelUCINaturalPerson(relUCINaturalPerson);
            // We must save now to generate the ID that will be put in RelUCIRelatedIndividual
            // PK (which is used as a FK). The model should be changed so that the PK is no longer used as a FK and
            // a FK table pointing to the RelUCINaturalPerson table is added
            relRelatedIndividual = relRelatedIndividualRepository.save(relRelatedIndividual);
            relUCIRelatedIndividual.setId(relRelatedIndividual.getId());
            relRelatedIndividual.setRelUCIRelatedIndividual(relUCIRelatedIndividual);
        }
        else {
            throw new BadRequestException("Payload must contain either a legal person xor a UCI entity");
        }
        relRelatedIndividual = relRelatedIndividualRepository.save(relRelatedIndividual);

        technicalAccessService.updateTechnicalTables(relRelatedIndividual.getId(), INTL_ID_ELEM_REL_IND);

        return relRelatedIndividualMapper.toDTO(relRelatedIndividual);
    }

    public Boolean hasActiveRelatedIndividualSubFund(Integer subFundId) {
        return CollectionUtils.isNotEmpty(this.getActiveRelatedIndividualsSubFund(subFundId));
    }

    public List<RelRelatedIndividualDTO> getAllRelatedIndividuals(Integer uciEntityId, Integer legalPersonId, Integer naturalPersonId, UUID taskUuid, boolean activeOnly) {
        List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();

        RelRelatedIndividualSearchCriteria relRelatedIndividualSearchCriteria = RelRelatedIndividualSearchCriteria.builder()
                .dataProfileIntlIds(dataProfilesUserIntlId)
                .uciEntityId(uciEntityId)
                .legalPersonId(legalPersonId)
                .naturalPersonId(naturalPersonId)
                .taskUuid(taskUuid)
                .activeDate(activeOnly ? LocalDate.now() : null)
                .build();

        List<RelRelatedIndividual> relatedIndividuals = relRelatedIndividualRepository.findAll(new RelRelatedIndividualSpecification(relRelatedIndividualSearchCriteria, relRelatedIndividualRules));

        return relRelatedIndividualMapper.toDTO(relatedIndividuals);
    }

    public List<RelRelatedIndividualDTO> getAllRelatedIndividualsByUciEntityId(Integer uciEntityId, boolean activeOnly) {
        return getAllRelatedIndividuals(uciEntityId, null, null, null, activeOnly);
    }

    public RelRelatedIndividualDTO getRelatedIndividualById(Integer id) {
        return relRelatedIndividualRepository.findById(id)
                .map(relRelatedIndividualMapper::toDTO)
                .orElseThrow(() -> makeResourceNotFoundException(id));
    }

    public List<RevisionDTO> getRiRevisionsById(Integer id) {
        List<RevisionDTO<RelatedIndividualDTOAudit>> revisionsByUUid = this.getRevisionsByUUid(id);
        return this.revisionMapper.map(revisionsByUUid);
    }

    public List<RevisionDiffItemDTO> getRiRevisionsDiff(Integer id, List<Integer> revisionIds) {
        return this.getRevisionsDiff(id, revisionIds);
    }

    public List<RevisionDiffItemDTO> getRiRevisionsDiffByTask(Integer id, UUID uuid) {
        return this.getRevisionsDiff(id, uuid.toString());
    }
    
    public RelRelatedIndividualDTO getRiRevisonRollbackFromTask(Integer id, UUID uuid) {
    	Integer revisionId = this.getRevisionIdFromTaskUuid(id, uuid.toString());
    	return relRelatedIndividualMapper.fromEntityRevisionToDTO(this.getEntityFromRevision(id, revisionId));
    }
    
    @HasAccess(EPBS_ROLE_REL_IND_UPDATE)
    public RelRelatedIndividualDTO updateRelRelatedIndividual(RelRelatedIndividualDTO relRelatedIndividualDTO) {
    	return repository.findById(Integer.valueOf(relRelatedIndividualDTO.getId()))
    			.map(ri -> {
    				relRelatedIndividualMapper.updateEntityFields(ri, relRelatedIndividualDTO);
    				ri.setTecUser(UserContext.getCurrentUser());
    				RelRelatedIndividual savedRelRelatedIndividual = repository.save(ri);
    				return relRelatedIndividualMapper.toDTO(savedRelRelatedIndividual);
    			})
                .orElseThrow(() -> makeResourceNotFoundException(Integer.valueOf(relRelatedIndividualDTO.getId())));
    }

    @HasAccess(EPBS_ROLE_REL_IND_DEACTIVATE)
    public RelRelatedIndividualDTO updateRelRelatedIndividualInactivate(Integer relRelatedEntityId, LocalDate endDate) {
        return repository.findById(relRelatedEntityId)
                .map(ri -> {
                	ri.setValidTo(endDate);
                	return relRelatedIndividualMapper.toDTO(repository.save(ri));
                })
                .orElseThrow(() -> makeResourceNotFoundException(relRelatedEntityId));
    }
    

    @Transactional
    public RelRelatedIndividualDTO updateRelRelatedIndividualUnlinkTask(Integer relRelatedIndividualId) {
        repository.unlinkTask(relRelatedIndividualId);
        return this.getRelatedIndividualById(relRelatedIndividualId);
    }

    @Transactional
    public RelRelatedIndividualDTO updateRelRelatedIndividualLinkTask(Integer relRelatedIndividualId, UUID taskUid) {
        repository.linkTask(relRelatedIndividualId, taskUid.toString());
        return this.getRelatedIndividualById(relRelatedIndividualId);
    }

    @Transactional
    @HasAccess(EPBS_ROLE_REL_IND_DELETE)
    public void deleteRelRelatedIndividual(Integer id) {
        RelRelatedIndividual relRelatedIndividual = relRelatedIndividualRepository.findById(id)
                .orElseThrow(() -> makeResourceNotFoundException(id));
        if (Objects.nonNull(relRelatedIndividual.getRelUCIRelatedIndividual())) {
            relUCIRelatedIndividualService.deleteById(id);
        }
        else if (Objects.nonNull(relRelatedIndividual.getRelLegalPersonRelatedIndividual())) {
            relLegalPersonRelatedIndividualService.deleteById(id);
        }
        else {
            throw new BadRequestException("Related individual with id " + id + " is neither linked to a UCI nor a LegalPerson");
        }
        relRelatedIndividualRepository.deleteById(id);
    }

    @Override
    protected RevisionDTO<RelatedIndividualDTOAudit> getRevisionDtoInstance() {
        final RevisionDTO<RelatedIndividualDTOAudit> revisionDTO = new RevisionDTO<>();
        revisionDTO.setEntity(new RelatedIndividualDTOAudit());
        revisionDTO.setMetadata(new RevisionMetadataDTO());
        return revisionDTO;
    }

    @Override
    protected void mapChild(RevisionDTO<RelatedIndividualDTOAudit> revisionDto, Revision<Integer, RelRelatedIndividual> revision) {
        revisionDto.setEntity(relatedIndividualAuditMapper.toRelatedIndividualDTOAudit(revision.getEntity()));
    }
    
    private List<RelRelatedIndividual> getActiveRelatedIndividualsSubFund(Integer subFundId) {
    	List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();
    	
        if (CollectionUtils.isNotEmpty(dataProfilesUserIntlId)) {

            RelRelatedIndividualSearchCriteria relRelatedIndividualSearchCriteria = RelRelatedIndividualSearchCriteria.builder()
                    .dataProfileIntlIds(dataProfilesUserIntlId)
                    .uciEntityId(subFundId)
                    .uciEntityTypeIntlId("subfund")
                    .activeDate(LocalDate.now())
                    .build();

            return relRelatedIndividualRepository.findAll(new RelRelatedIndividualSpecification(relRelatedIndividualSearchCriteria, relRelatedIndividualRules));
        }
        return Collections.emptyList();
    }

    private ResourceNotFoundException makeResourceNotFoundException(Integer riId) {
        return new ResourceNotFoundException("Related Individual " + riId + " not found");
    }
    
}
