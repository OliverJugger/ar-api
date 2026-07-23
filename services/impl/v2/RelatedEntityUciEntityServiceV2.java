package com.bdl.epbs_fund_api.services.impl.v2;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Stream;

import org.apache.commons.lang3.StringUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.data.domain.Sort.Order;
import org.springframework.data.history.Revisions;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.domain.RelatedEntityUciV2Search;
import com.bdl.epbs_fund_api.mappings.v2.RelRelatedEntityMapperV2;
import com.bdl.epbs_fund_api.mappings.v2.RevisionRelatedEntityUciMapperV2;
import com.bdl.epbs_fund_api.model.ElemTypeEnumDTO;
import com.bdl.epbs_fund_api.model.RelatedEntityUciAuditedV2DTO;
import com.bdl.epbs_fund_api.model.RelatedEntityUciInsertV2DTO;
import com.bdl.epbs_fund_api.model.RelatedEntityUciV2DTO;
import com.bdl.epbs_fund_api.model.RevisionRelatedEntityUciV2DTO;
import com.bdl.epbs_fund_api.model.entities.Segment;
import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.model.relations.RelRelatedEntity;
import com.bdl.epbs_fund_api.repositories.RelRelatedEntityRepository;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.services.impl.SubFundService;
import com.bdl.epbs_fund_api.specification.RelRelatedEntitySpecification;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedEntitySearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.rel_related_entity.RelRelatedEntityRule;
import com.bdl.epbs_fund_api.utils.RevisionUtils;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RelatedEntityUciEntityServiceV2 implements SyncAuditService {

	private final SubFundService subFundService;
    private final RelRelatedEntityMapperV2 relRelatedEntityMapperV2;
    private final RevisionRelatedEntityUciMapperV2 revisionRelatedEntityUciMapperV2;
    private final TechnicalAccessService technicalAccessService;
    private final List<RelRelatedEntityRule> relRelatedEntityRules;
    private final RelRelatedEntityRepository relRelatedEntityRepository;

    private static final String VALID_FROM = "validFrom";
    private static final String ID = "id";
    
    public RelatedEntityUciV2DTO getRelatedEntityUciV2(Integer relatedEntityUciId) {
    	return relRelatedEntityMapperV2.toDTO(
    			relRelatedEntityRepository.findById(relatedEntityUciId)
    				.orElseThrow(() -> new ResourceNotFoundException("Could not find related entity by id : " + relatedEntityUciId)));
    }
    
	public Page<RelatedEntityUciV2DTO> getFundRelatedEntitiesUciV2(Integer fundId, RelatedEntityUciV2Search search, Integer page, Integer size) {
		return searchRelatedEntities(List.of(fundId), null, null, search, page, size)
				.map(relRelatedEntityMapperV2::toDTO);
	}

    public Page<RelatedEntityUciV2DTO> getSubFundRelatedEntitiesUciV2(Integer subFundId, RelatedEntityUciV2Search search, Integer page, Integer size) {
		
    	List<Integer> uciEntityIds = Optional.ofNullable(search.getSegmentId())
    			.map(List::of)
	    		.orElseGet(() -> {
					SubFund subFund = subFundService.getSubFundByIdInternal(subFundId);
					return Stream.concat(
								Stream.of(subFundId),
								subFund.getSegments()
									.stream()
									.map(Segment::getId)
								).toList();
	    		});

		return searchRelatedEntities(uciEntityIds, null, null, search, page, size)
				.map(relRelatedEntityMapperV2::toDTO);
	}
    
    public List<RevisionRelatedEntityUciV2DTO> getRelatedEntityUciRevisionsByIdV2(Integer relatedEntityUciId) {
    	
    	Revisions<Integer, RelRelatedEntity> revisions = relRelatedEntityRepository.findRevisions(relatedEntityUciId);
		
		List<RevisionRelatedEntityUciV2DTO> revisionRelatedEntities = revisions
				.stream()
				.map(revisionRelatedEntityUciMapperV2::fromEntityToDTO)
				.toList();
		
		return RevisionUtils.<RevisionRelatedEntityUciV2DTO, RelatedEntityUciAuditedV2DTO> sortRevisionsAndOrganise(
				revisionRelatedEntities, 
				(r1, r2) -> Integer.compare(r2.getId(), r1.getId()),
				RevisionRelatedEntityUciV2DTO::getAfter, 
				RevisionRelatedEntityUciV2DTO::getBefore,
				RevisionRelatedEntityUciV2DTO::setBefore,
				relRelatedEntityMapperV2);
    }
    
    public RevisionRelatedEntityUciV2DTO getRelatedEntityUciRevisionsByIdAndTaskId(Integer relatedEntityUciId, UUID taskId) {
    	List<RevisionRelatedEntityUciV2DTO> revisions = getRelatedEntityUciRevisionsByIdV2(relatedEntityUciId);
    	
    	return revisions.stream()
    		.filter(rev -> StringUtils.equalsIgnoreCase(rev.getAfter().getTaskUid(), taskId.toString()))
    		.findAny()
    		.orElse(null);
    }
    
    public RelatedEntityUciV2DTO updateRelatedEntityUciV2(Integer relatedEntityUciId, Integer fromId, ElemTypeEnumDTO fromType, RelatedEntityUciInsertV2DTO relatedEntityUciV2DTO) {
    	
    	RelRelatedEntity relatedEntityToSave = relRelatedEntityMapperV2.toEntity(fromId, fromType, relatedEntityUciV2DTO);
    	relatedEntityToSave.setId(relatedEntityUciId);
    	
    	RelRelatedEntity result = relRelatedEntityRepository.save(relatedEntityToSave);
    	
    	return relRelatedEntityMapperV2.toDTO(result);    	
    }
    
    public RelatedEntityUciV2DTO createRelatedEntityUciV2(Integer fromId, ElemTypeEnumDTO fromType, RelatedEntityUciInsertV2DTO relatedEntityUciV2DTO) {
    	
    	RelRelatedEntity relatedEntityToSave = relRelatedEntityMapperV2.toEntity(fromId, fromType, relatedEntityUciV2DTO);
    	
    	RelRelatedEntity result = relRelatedEntityRepository.save(relatedEntityToSave);
    	
		technicalAccessService.updateTechnicalTables(result.getId(), Constants.INTL_ID_ELEM_REL_ENT);
    	
    	return relRelatedEntityMapperV2.toDTO(result);    	
    }
    
    @Override
    public List<Integer> getDesynchronizedIds() {
        return relRelatedEntityRepository.findAll()
                .stream()
                .filter(this::isLastChangeRevision)
                .map(RelRelatedEntity::getId)
                .toList();
    }

    @Override
    public void forceAudit(List<Integer> desynchronizedIds) {
        List<RelRelatedEntity> subFundForceAudits = relRelatedEntityRepository.findAllById(desynchronizedIds)
                .stream()
                .map(this::updateForceAuditVersions)
                .toList();

        relRelatedEntityRepository.saveAll(subFundForceAudits);
    }
    
    private boolean isLastChangeRevision(RelRelatedEntity subFund) {
        return relRelatedEntityRepository.findLastChangeRevision(subFund.getId())
                .map(lastAudit -> {
                	RelatedEntityUciAuditedV2DTO lastValue = relRelatedEntityMapperV2.toAuditDTO(lastAudit.getEntity());
                	RelatedEntityUciAuditedV2DTO actualValue = relRelatedEntityMapperV2.toAuditDTO(subFund);
                    return !relRelatedEntityMapperV2.toAuditedEquals(lastValue).equals(relRelatedEntityMapperV2.toAuditedEquals(actualValue));
                }).orElse(false);
    }

    private RelRelatedEntity updateForceAuditVersions(RelRelatedEntity relatedEntity) {
    	relatedEntity.setForceAuditVersion(RevisionUtils.incrementAuditVersion(relatedEntity.getForceAuditVersion()));
        return relatedEntity;
    }
    
    private Page<RelRelatedEntity> searchRelatedEntities(List<Integer> uciEntityIds, Integer legalPersonId, UUID taskUid, RelatedEntityUciV2Search search, Integer page, Integer size) {
    	
        List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();

        RelRelatedEntitySearchCriteria relRelatedEntitySearchCriteria = RelRelatedEntitySearchCriteria.builder()
                .dataProfileIntlIds(dataProfilesUserIntlId)
                .uciEntityIds(uciEntityIds)
                .legalPersonId(legalPersonId)
                .legalPersonName(search.getLegalPersonNameContains())
                .startDateStart(search.getStartDateStart())
                .startDateEnd(search.getStartDateEnd())
                .endDateStart(search.getEndDateStart())
                .endDateEnd(search.getEndDateEnd())
                .relatedEntityType(search.getType())
                .activeDate(search.isActiveOnly() ? LocalDate.now() : null)
                .taskUid(taskUid)
                .build();

        List<Order> orders = List.of(
        		new Order(Direction.DESC, VALID_FROM),
        		new Order(Direction.DESC, ID));

        return relRelatedEntityRepository.findAll(
        		new RelRelatedEntitySpecification(relRelatedEntitySearchCriteria, relRelatedEntityRules),
        			PageRequest.of(page, size, Sort.by(orders)));
    }
    
}
