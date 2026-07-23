package com.bdl.epbs_fund_api.services.impl.v2;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import org.apache.commons.lang3.StringUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.data.domain.Sort.Order;
import org.springframework.data.history.Revision;
import org.springframework.data.history.Revisions;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.domain.RelatedIndividualV2Search;
import com.bdl.epbs_fund_api.mappings.v2.RelRelatedIndividualMapperV2;
import com.bdl.epbs_fund_api.mappings.v2.RevisionRelatedIndividualMapperV2;
import com.bdl.epbs_fund_api.model.ElemTypeEnumDTO;
import com.bdl.epbs_fund_api.model.RelatedIndividualAuditedV2DTO;
import com.bdl.epbs_fund_api.model.RelatedIndividualInsertV2DTO;
import com.bdl.epbs_fund_api.model.RelatedIndividualV2DTO;
import com.bdl.epbs_fund_api.model.RevisionRelatedIndividualV2DTO;
import com.bdl.epbs_fund_api.model.relations.v2.RelRelatedIndividualV2;
import com.bdl.epbs_fund_api.repositories.v2.RelRelatedIndividualRepositoryV2;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.rel_related_individual_v2.RelRelatedIndividualRuleV2;
import com.bdl.epbs_fund_api.specification.v2.RelRelatedIndividualSpecificationV2;
import com.bdl.epbs_fund_api.utils.RevisionUtils;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RelRelatedIndividualServiceV2 implements SyncAuditService {

	private final RelRelatedIndividualMapperV2 relatedIndividualMapperV2;
    private final RevisionRelatedIndividualMapperV2 revisionRelatedIndividualMapperV2;
    private final TechnicalAccessService technicalAccessService;
    private final List<RelRelatedIndividualRuleV2> relRelatedIndividualRules;
    private final RelRelatedIndividualRepositoryV2 relRelatedIndividualRepository;

    private static final String VALID_FROM = "validFrom";
    private static final String ID = "id";

    public RelatedIndividualV2DTO getRelatedIndividualById(Integer id) {
        return relRelatedIndividualRepository.findById(id)
                .map(relatedIndividualMapperV2::toDTO)
                .orElseThrow(() -> new ResourceNotFoundException("Related Individual " + id + " not found"));
    }
    
    public Page<RelatedIndividualV2DTO> getAllUCIRelatedIndividuals(Integer uciEntityId, RelatedIndividualV2Search search, Integer page, Integer size) {
        List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();

        RelRelatedIndividualSearchCriteria relRelatedIndividualSearchCriteria = RelRelatedIndividualSearchCriteria.builder()
                .dataProfileIntlIds(dataProfilesUserIntlId)
                .uciEntityId(uciEntityId)
                .relatedIndividualTypeCategory(search.getCategory())
                .relatedIndividualType(search.getType())
                .naturalPersonNameContains(search.getNaturalPersonNameContains())
                .startDateStart(search.getStartDateStart())
                .startDateEnd(search.getStartDateEnd())
                .endDateStart(search.getEndDateStart())
                .endDateEnd(search.getEndDateEnd())
                .activeDate(search.isActiveOnly() ? LocalDate.now() : null)
                .build();

        List<Order> orders = List.of(
        		new Order(Direction.DESC, VALID_FROM),
        		new Order(Direction.DESC, ID));
        
        return relRelatedIndividualRepository.findAll(
                new RelRelatedIndividualSpecificationV2(relRelatedIndividualSearchCriteria, relRelatedIndividualRules),
                        PageRequest.of(page, size, Sort.by(orders)))
                .map(relatedIndividualMapperV2::toDTO);
    }

    public RelatedIndividualV2DTO updateRelatedIndividualV2(Integer relatedIndividualId, Integer fromId, ElemTypeEnumDTO fromType, RelatedIndividualInsertV2DTO relatedIndividualDTO) {
    	RelRelatedIndividualV2 relatedIndividualToSave = relatedIndividualMapperV2.toEntity(fromId, fromType, relatedIndividualId, relatedIndividualDTO);
    	
    	RelRelatedIndividualV2 result = relRelatedIndividualRepository.save(relatedIndividualToSave);
    	
    	return relatedIndividualMapperV2.toDTO(result);   
    }

    public RelatedIndividualV2DTO createRelatedIndividualV2(Integer fromId, ElemTypeEnumDTO fromType, RelatedIndividualInsertV2DTO relatedIndividualDTO) {
    	RelRelatedIndividualV2 result = saveRelatedIndividual(fromId, fromType, relatedIndividualDTO);
    	
        technicalAccessService.updateTechnicalTables(result.getId(), ElemTypeEnumDTO.RELATED_INDIVIDUAL.getValue());
        return relatedIndividualMapperV2.toDTO(result);
    }
    
    public void deleteRelatedIndividualV2(Integer relatedIndividualId) {
    	relRelatedIndividualRepository.deleteById(relatedIndividualId);
    }
    
    public RelatedIndividualV2DTO putRevertRelatedIndividualV2(Integer relatedIndividualId) {
    	return relRelatedIndividualRepository.findById(relatedIndividualId)
	    		.map(relatedIndividual -> {
	    	    	List<Revision<Integer, RelRelatedIndividualV2>> revisions = relRelatedIndividualRepository.findRevisions(relatedIndividualId).getContent();
	    	    	
	    	    	RelRelatedIndividualV2 lastValue = revisions.get(revisions.size()-2).getEntity();
	
	    	    	relatedIndividual.setValidFrom(lastValue.getValidFrom());
	    	    	relatedIndividual.setValidTo(lastValue.getValidTo());
	    	    	relatedIndividual.setJobTitle(lastValue.getJobTitle());
	    	    	relatedIndividual.setPercentageDetention(lastValue.getPercentageDetention());
	    	    	relatedIndividual.setTaskUid(null);
	    	    	
	    	    	return relRelatedIndividualRepository.save(relatedIndividual);
	    		})
	    		.map(relatedIndividualMapperV2::toDTO)
	    		.orElseThrow(() -> new ResourceNotFoundException("Related Individual " + relatedIndividualId + " not found"));
    }
    
    public List<RevisionRelatedIndividualV2DTO> getRelatedIndividualRevisionsByIdV2(Integer relatedIndividualId) {
    	
    	Revisions<Integer, RelRelatedIndividualV2> revisions = relRelatedIndividualRepository.findRevisions(relatedIndividualId);
		
		List<RevisionRelatedIndividualV2DTO> revisionRelatedIndividuals = revisions
				.stream()
				.map(revisionRelatedIndividualMapperV2::fromEntityToDTO)
				.toList();
		
		return RevisionUtils.sortRevisionsAndOrganise(
						revisionRelatedIndividuals, 
						(r1, r2) -> Integer.compare(r2.getId(), r1.getId()),
						RevisionRelatedIndividualV2DTO::getAfter, 
						RevisionRelatedIndividualV2DTO::getBefore, 
						RevisionRelatedIndividualV2DTO::setBefore,
						relatedIndividualMapperV2);
    } 
    
    public RevisionRelatedIndividualV2DTO getRelatedIndividualRevisionsByIdAndTaskId(Integer relatedIndividualId, UUID taskId) {
    	List<RevisionRelatedIndividualV2DTO> revisions = getRelatedIndividualRevisionsByIdV2(relatedIndividualId);
    	
    	return revisions.stream()
    		.filter(rev -> StringUtils.equalsIgnoreCase(rev.getAfter().getTaskUid(), taskId.toString()))
    		.findAny()
    		.orElse(null);
    }
    
    @Override
    public List<Integer> getDesynchronizedIds() {
        return relRelatedIndividualRepository.findAll()
                .stream()
                .filter(this::isLastChangeRevision)
                .map(RelRelatedIndividualV2::getId)
                .toList();
    }

    @Override
    public void forceAudit(List<Integer> desynchronizedIds) {
        List<RelRelatedIndividualV2> subFundForceAudits = relRelatedIndividualRepository.findAllById(desynchronizedIds)
                .stream()
                .map(this::updateForceAuditVersions)
                .toList();

        relRelatedIndividualRepository.saveAll(subFundForceAudits);
    }
    
    private boolean isLastChangeRevision(RelRelatedIndividualV2 relatedIndividual) {
        return relRelatedIndividualRepository.findLastChangeRevision(relatedIndividual.getId())
                .map(lastAudit -> {
                	RelatedIndividualAuditedV2DTO lastValue = relatedIndividualMapperV2.toAuditDTO(lastAudit.getEntity());
                	RelatedIndividualAuditedV2DTO actualValue = relatedIndividualMapperV2.toAuditDTO(relatedIndividual);
                    return !relatedIndividualMapperV2.toAuditedEquals(lastValue).equals(relatedIndividualMapperV2.toAuditedEquals(actualValue));
                }).orElse(false);
    }

    private RelRelatedIndividualV2 updateForceAuditVersions(RelRelatedIndividualV2 relatedIndividual) {
    	relatedIndividual.setForceAuditVersion(RevisionUtils.incrementAuditVersion(relatedIndividual.getForceAuditVersion()));
        return relatedIndividual;
    }
    
    @Transactional
    private RelRelatedIndividualV2 saveRelatedIndividual(Integer fromId, ElemTypeEnumDTO fromType, RelatedIndividualInsertV2DTO relatedIndividualDTO) {
    	RelRelatedIndividualV2 relatedIndividualToSave = relatedIndividualMapperV2.toEntity(fromId, fromType, null, relatedIndividualDTO);
    	return relRelatedIndividualRepository.save(relatedIndividualToSave);
    }

}
