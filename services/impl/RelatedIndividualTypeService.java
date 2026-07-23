package com.bdl.epbs_fund_api.services.impl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.mappings.RelatedIndividualTypeMapper;
import com.bdl.epbs_fund_api.mappings.v2.RelatedIndividualTypeMapperV2;
import com.bdl.epbs_fund_api.model.ElemRelationTypeEnumDTO;
import com.bdl.epbs_fund_api.model.ElemTypeEnumDTO;
import com.bdl.epbs_fund_api.model.MasterRecordStorageDTO;
import com.bdl.epbs_fund_api.model.RelatedIndividualCategoryIdDTO;
import com.bdl.epbs_fund_api.model.RelatedIndividualTypeDTO;
import com.bdl.epbs_fund_api.model.RelatedIndividualTypeV2DTO;
import com.bdl.epbs_fund_api.model.SourceSystemEnumDTO;
import com.bdl.epbs_fund_api.model.types.RelatedIndividualType;
import com.bdl.epbs_fund_api.repositories.type.RelatedIndividualTypeRepository;
import com.bdl.epbs_fund_api.services.access.impl.FeatureService;
import com.bdl.epbs_fund_api.services.metadata.impl.MasterRecordStorageService;
import com.bdl.epbs_fund_api.specification.RelatedIndividualTypeSpecification;
import com.bdl.epbs_fund_api.specification.criteria.RelatedIndividualTypeSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.related_individual_type.RelatedIndividualTypeRule;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class RelatedIndividualTypeService {

	private final RelatedIndividualTypeMapper relatedIndividualTypeMapper;
	private final RelatedIndividualTypeMapperV2 relatedIndividualTypeMapperV2;

	private final FeatureService featureService;

	private final MasterRecordStorageService masterRecordStorageService;

	private final RelatedIndividualTypeRepository relatedIndividualTypeRepository;  
	
	private final List<RelatedIndividualTypeRule> relatedIndividualTypeRule;
	
    private static final String NAME = "name";
	
	private final Map<String, String> featureNameRIName = Map.of(
			Constants.INTL_ID_FEATURE_CUD_RI_MEMBER_OF_BOARD, Constants.INTL_ID_TYPE_RI_MEMBER_OF_BOARD, 
			Constants.INTL_ID_FEATURE_CUD_RI_PRESIDENT_OF_BOARD, Constants.INTL_ID_TYPE_RI_PRESIDENT_OF_BOARD,
			Constants.INTL_ID_FEATURE_CUD_RI_BENEFICIAL_OWNER, Constants.INTL_ID_TYPE_RI_BENEFICIAL_OWNER,
			Constants.INTL_ID_FEATURE_CUD_RI_BENEFICIAL_OWNER_PERSON, Constants.INTL_ID_TYPE_RI_BENEFICIAL_OWNER_PERSON);

	public List<RelatedIndividualTypeDTO> getAllRelatedIndividualType() {
		return relatedIndividualTypeMapper.toDTO(relatedIndividualTypeRepository.findAll());
	}

	public List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeOfFund() {
		return relatedIndividualTypeMapper.toDTO(this.relatedIndividualTypeRepository.findAll()
				.stream().filter(RelatedIndividualType::getIsFund).toList());
	}

	//bad naming
    @Deprecated(since = "25/03/2025")
	public List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeByCategory(RelatedIndividualCategoryIdDTO relatedIndividualCategory, Integer id) {
		if (relatedIndividualCategory != null) {
			return switch (relatedIndividualCategory) {
				case FUND -> getAllRelatedIndividualTypeOfFund(id);
				case SUB_FUND -> getAllRelatedIndividualTypeOfSubFund(id);
				case LEGAL_PERSON -> getAllRelatedIndividualTypeOfLegalPerson(id);
				default -> Collections.emptyList();
			};
		}

		return this.getAllRelatedIndividualType();
	}
    
    public List<RelatedIndividualTypeV2DTO> getAllRelatedIndividualTypesV2(ElemRelationTypeEnumDTO isElementType) {

    	Optional<ElemRelationTypeEnumDTO> isElementTypeNullable = Optional.ofNullable(isElementType);
    	
    	RelatedIndividualTypeSearchCriteria relatedIndividualTypeSearchCriteria = RelatedIndividualTypeSearchCriteria.builder()
                .isFund(isElementTypeNullable.map(ElemRelationTypeEnumDTO.FUND::equals).orElse(null))
                .isSubFund(isElementTypeNullable.map(ElemRelationTypeEnumDTO.SUBFUND::equals).orElse(null))
                .isLegalPerson(isElementTypeNullable.map(ElemRelationTypeEnumDTO.LEGAL_PERSON::equals).orElse(null))
                .build();

        List<RelatedIndividualType> relatedIndividualTypes =  relatedIndividualTypeRepository.findAll(
        		new RelatedIndividualTypeSpecification(relatedIndividualTypeSearchCriteria, relatedIndividualTypeRule),
        		Sort.by(NAME));

    	return relatedIndividualTypeMapperV2.toDTO(relatedIndividualTypes);
	}
    
    public RelatedIndividualType getRelatedIndividualTypeByIntlIdInternal(String intlId) {
		return relatedIndividualTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("Could not find related entity type with intlId : " + intlId));
	}
    
	/**
	 * It seems that we don't need to hide RI that are disabled : TODO : Check
	 * without this filter
	 */
	private List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeOfFund(Integer fundId) {
		log.info("Entry for RelatedIndividualTypeService::getAllRelatedIndividualTypeOfFund with parameter :" + fundId);

		if (fundId == null) {
			return getAllRelatedIndividualTypeOfFund();
		}

		List<RelatedIndividualType> types = this.relatedIndividualTypeRepository.findAll().stream()
				.filter(RelatedIndividualType::getIsFund).toList();
		
		MasterRecordStorageDTO masterRecordStorage = masterRecordStorageService.findByEpbsIdAndElemTypeIntlId(fundId,
				ElemTypeEnumDTO.FUND.getValue());

		List<String> disabledRiTypesIntlIds = Optional.ofNullable(masterRecordStorage)
					.map(MasterRecordStorageDTO::getMasterSourceSystem)
					.map(SourceSystemEnumDTO::getValue)
					.filter(sourceSystem -> SourceSystemEnumDTO.AVALOQ.getValue().equals(sourceSystem))
					.map(m -> getDisabledFeature())
					.orElse(Collections.emptyList());

		types = types.stream()
					.filter(type -> !disabledRiTypesIntlIds.contains(type.getIntlId()))
					.toList();
		
		return relatedIndividualTypeMapper.toDTO(types);
	}

	private List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeOfSubFund(Integer subFundId) {
		log.info("Entry for RelatedIndividualTypeService::getAllRelatedIndividualTypeOfSubFund with parameter :" + subFundId);
		
		List<RelatedIndividualType> types = this.relatedIndividualTypeRepository.findAll().stream()
				.filter(RelatedIndividualType::getIsSubFund)
				.toList();

		MasterRecordStorageDTO masterRecordStorage = masterRecordStorageService.findByEpbsIdAndElemTypeIntlId(
				subFundId,
				ElemTypeEnumDTO.SUBFUND.getValue());

		if (masterRecordStorage == null) {
			return Collections.emptyList();
		} else if (SourceSystemEnumDTO.AVALOQ.equals(masterRecordStorage.getMasterSourceSystem())) {
			List<String> disabledRiTypesIntlIds = new ArrayList<>();
			
			featureService.getAll().stream().filter(feature -> Boolean.FALSE.equals(feature.getEnabled()))
					.forEach(feature -> {
						if (Constants.INTL_ID_FEATURE_CUD_RI_MIFIR_DECISION_TAKER.equals(feature.getIntlId()))
							disabledRiTypesIntlIds.add(Constants.INTL_ID_TYPE_RI_MIFIR_DECISION_TAKER);
					});

			return relatedIndividualTypeMapper.toDTO(types.stream()
					.filter(type -> !(disabledRiTypesIntlIds.contains(type.getIntlId())))
					.toList());
		}
		return relatedIndividualTypeMapper.toDTO(types);
	}

	private List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeOfLegalPerson(Integer legalPersonId) {
		log.info("Entry for RelatedIndividualTypeService::getAllRelatedIndividualTypeOfLegalPerson with parameter :" + legalPersonId);
		List<RelatedIndividualType> types = this.relatedIndividualTypeRepository.findAll().stream()
				.filter(RelatedIndividualType::getIsLegalPerson)
				.toList();

		MasterRecordStorageDTO masterRecordStorage = masterRecordStorageService.findByEpbsIdAndElemTypeIntlId(
				legalPersonId, 
				ElemTypeEnumDTO.LEGAL_PERSON.getValue());

		if (masterRecordStorage == null) {
			return Collections.emptyList();
		} else if (SourceSystemEnumDTO.AVALOQ.equals(masterRecordStorage.getMasterSourceSystem())) {
			List<String> disabledRiTypesIntlIds = new ArrayList<>();
			featureService.getAll().stream().filter(feature -> Boolean.FALSE.equals(feature.getEnabled()))
					.forEach(feature -> {
						if (Constants.INTL_ID_FEATURE_CUD_RI_BENEFICIAL_OWNER.equals(feature.getIntlId()))
							disabledRiTypesIntlIds.add(Constants.INTL_ID_TYPE_RI_BENEFICIAL_OWNER);
						if (Constants.INTL_ID_FEATURE_CUD_RI_BENEFICIAL_OWNER_PERSON.equals(feature.getIntlId()))
							disabledRiTypesIntlIds.add(Constants.INTL_ID_TYPE_RI_BENEFICIAL_OWNER_PERSON);
						if (Constants.INTL_ID_FEATURE_CUD_RI_EXECUTIVE.equals(feature.getIntlId()))
							disabledRiTypesIntlIds.add(Constants.INTL_ID_TYPE_RI_EXECUTIVE);
					});

			return relatedIndividualTypeMapper.toDTO(types.stream()
					.filter(type -> !disabledRiTypesIntlIds.contains(type.getIntlId()))
					.toList());
		}
		return relatedIndividualTypeMapper.toDTO(types);
	}
	
	private List<String> getDisabledFeature() {
		return featureService.getAll().stream()
				.filter(feature -> Boolean.FALSE.equals(feature.getEnabled()) && featureNameRIName.keySet().contains(feature.getIntlId()))
				.map(feature -> featureNameRIName.get(feature.getIntlId()))
				.toList();
	}

}
