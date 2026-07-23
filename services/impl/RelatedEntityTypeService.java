package com.bdl.epbs_fund_api.services.impl;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.RelatedEntityTypeMapper;
import com.bdl.epbs_fund_api.mappings.v2.RelatedEntityTypeMapperV2;
import com.bdl.epbs_fund_api.model.ElemRelationTypeEnumDTO;
import com.bdl.epbs_fund_api.model.RelatedEntityTypeDTO;
import com.bdl.epbs_fund_api.model.RelatedEntityTypeV2DTO;
import com.bdl.epbs_fund_api.model.types.RelatedEntityType;
import com.bdl.epbs_fund_api.repositories.type.RelatedEntityTypeRepository;
import com.bdl.epbs_fund_api.specification.RelatedEntityTypeSpecification;
import com.bdl.epbs_fund_api.specification.criteria.RelatedEntityTypeSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.related_entity_type.RelatedEntityTypeRule;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RelatedEntityTypeService {

	private final RelatedEntityTypeMapper relatedEntityTypeMapper;
	
	private final RelatedEntityTypeMapperV2 relatedEntityTypeMapperV2;

	private final RelatedEntityTypeRepository relatedEntityTypeRepository;

    private final List<RelatedEntityTypeRule> relatedEntityTypeRules;
    
    private static final String INTL_ID = "intlId";
    
	@Deprecated(since="25/03/2025")
    public List<RelatedEntityTypeDTO> getAllRelatedEntityTypes(Boolean isFund,
			Boolean isSubFund, Boolean isSegment, Boolean isLegalPerson,
			Boolean isOnboarding, Boolean isDelegation, Boolean isAdvisedBy,
			Boolean isAvaloq) {

        RelatedEntityTypeSearchCriteria relRelatedEntitySearchCriteria = RelatedEntityTypeSearchCriteria.builder()
                .isFund(isFund)
                .isSubFund(isSubFund)
                .isSegment(isSegment)
                .isLegalPerson(isLegalPerson)
                .isOnboarding(isOnboarding)
                .isDelegation(isDelegation)
                .isAdvisedBy(isAdvisedBy)
                .isAvaloq(isAvaloq)
                .build();

        List<RelatedEntityType> relatedEntityTypes =  relatedEntityTypeRepository.findAll(new RelatedEntityTypeSpecification(relRelatedEntitySearchCriteria, relatedEntityTypeRules));

    	return relatedEntityTypeMapper.toDTO(relatedEntityTypes);
    }
    
    public List<RelatedEntityTypeV2DTO> getAllRelatedEntityTypesV2(ElemRelationTypeEnumDTO isElementType) {

    	Optional<ElemRelationTypeEnumDTO> isElementTypeNullable = Optional.ofNullable(isElementType);
    	
        RelatedEntityTypeSearchCriteria relRelatedEntityTypeSearchCriteria = RelatedEntityTypeSearchCriteria.builder()
        		.isFund(isElementTypeNullable.map(ElemRelationTypeEnumDTO.FUND::equals).orElse(null))
                .isSubFund(isElementTypeNullable.map(ElemRelationTypeEnumDTO.SUBFUND::equals).orElse(null))
                .isLegalPerson(isElementTypeNullable.map(ElemRelationTypeEnumDTO.LEGAL_PERSON::equals).orElse(null))
                .build();

        List<RelatedEntityType> relatedEntityTypes =  relatedEntityTypeRepository.findAll(
        		new RelatedEntityTypeSpecification(relRelatedEntityTypeSearchCriteria, relatedEntityTypeRules),
        		Sort.by(INTL_ID));

    	return relatedEntityTypeMapperV2.toDTO(relatedEntityTypes);
    }
    
    public RelatedEntityType getRelatedEntityTypeByIntlIdInternal(String intlId) {
		return relatedEntityTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("Could not find related entity type with intlId : " + intlId));
	}

	public RelatedEntityTypeDTO getRelatedEntityTypeByIntlId(String intlId) {
		return relatedEntityTypeRepository.findByIntlId(intlId)
				.map(relatedEntityTypeMapper::toDTO)
				.orElse(null);
	}
}
