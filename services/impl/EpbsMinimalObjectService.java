package com.bdl.epbs_fund_api.services.impl;

import java.util.Comparator;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Stream;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.ElemTypeEnumDTO;
import com.bdl.epbs_fund_api.model.EpbsMinimalObjectDTO;
import com.bdl.epbs_fund_api.model.EpbsMinimalObjectSearchDTO;
import com.bdl.epbs_fund_api.repositories.FundRepository;
import com.bdl.epbs_fund_api.repositories.IProjectDescriptionsRepository;
import com.bdl.epbs_fund_api.repositories.LegalPersonRepository;
import com.bdl.epbs_fund_api.repositories.NaturalPersonRepository;
import com.bdl.epbs_fund_api.repositories.SegmentRepository;
import com.bdl.epbs_fund_api.repositories.SubFundRepository;
import com.bdl.epbs_fund_api.utils.EpbsMinimalObjectUtils;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EpbsMinimalObjectService {

    private final FundRepository fundRepository;

    private final SubFundRepository subFundRepository;

    private final SegmentRepository segmentRepository;

    private final NaturalPersonRepository naturalPersonRepository;

    private final LegalPersonRepository legalPersonRepository;

    private final IProjectDescriptionsRepository projectDescriptionsRepository;
    
    public List<EpbsMinimalObjectDTO> getAllEpbsMinimalObjectsFromSearch(List<EpbsMinimalObjectSearchDTO> epbsMinimalObjectSearchDTO) {
    	final Map<ElemTypeEnumDTO, Function<List<Integer>, Stream<EpbsMinimalObjectDTO>>> elementsFindByIds = Map.of(
				ElemTypeEnumDTO.FUND, this::findFundsByIds,
				ElemTypeEnumDTO.SUBFUND, this::findSubFundsByIds,
				ElemTypeEnumDTO.SEGMENT, this::findSegmentsByIds,
				ElemTypeEnumDTO.NATURAL_PERSON, this::findNaturalPersonsByIds,
				ElemTypeEnumDTO.LEGAL_PERSON, this::findLegalPersonsByIds,
				ElemTypeEnumDTO.PROJECT, this::findProjectsByIds);
    	
    	EnumMap<ElemTypeEnumDTO, List<Integer>> elementsToFindByIds = new EnumMap<>(ElemTypeEnumDTO.class);
    	EnumMap<ElemTypeEnumDTO, List<Integer>> elementIdsMap = new EnumMap<>(ElemTypeEnumDTO.class);

    	elementIdsMap.put(ElemTypeEnumDTO.FUND, getObjectIdsFromElemType(epbsMinimalObjectSearchDTO, ElemTypeEnumDTO.FUND));
    	elementIdsMap.put(ElemTypeEnumDTO.SUBFUND, getObjectIdsFromElemType(epbsMinimalObjectSearchDTO, ElemTypeEnumDTO.SUBFUND));
    	elementIdsMap.put(ElemTypeEnumDTO.SEGMENT, getObjectIdsFromElemType(epbsMinimalObjectSearchDTO, ElemTypeEnumDTO.SEGMENT));
    	elementIdsMap.put(ElemTypeEnumDTO.NATURAL_PERSON, getObjectIdsFromElemType(epbsMinimalObjectSearchDTO, ElemTypeEnumDTO.NATURAL_PERSON));
    	elementIdsMap.put(ElemTypeEnumDTO.LEGAL_PERSON, getObjectIdsFromElemType(epbsMinimalObjectSearchDTO, ElemTypeEnumDTO.LEGAL_PERSON));
    	elementIdsMap.put(ElemTypeEnumDTO.PROJECT, getObjectIdsFromElemType(epbsMinimalObjectSearchDTO, ElemTypeEnumDTO.PROJECT));

    	for (Map.Entry<ElemTypeEnumDTO, List<Integer>> entry : elementIdsMap.entrySet()) {
    	    if (CollectionUtils.isNotEmpty(entry.getValue())) {
    	        elementsToFindByIds.put(entry.getKey(), entry.getValue());
    	    }
    	}
    	
    	return elementsToFindByIds.keySet()
    		.stream()
			.map(elementToFindByIds -> elementsFindByIds.get(elementToFindByIds).apply(elementsToFindByIds.get(elementToFindByIds)))
			.flatMap(i -> i)
			.toList();
    }

	public List<EpbsMinimalObjectDTO> getAllEpbsMinimalObjects(String name, List<ElemTypeEnumDTO> objectTypes) {
		final Map<ElemTypeEnumDTO, Function<String, Stream<EpbsMinimalObjectDTO>>> elementsFindByName = Map.of(
				ElemTypeEnumDTO.FUND, this::findFundByName,
				ElemTypeEnumDTO.SUBFUND, this::findSubFundByName,
				ElemTypeEnumDTO.SEGMENT, this::findSegmentByName,
				ElemTypeEnumDTO.NATURAL_PERSON, this::findNaturalPersonByName,
				ElemTypeEnumDTO.LEGAL_PERSON, this::findLegalPersonByName,
				ElemTypeEnumDTO.PROJECT, this::findProjectByName);
		
		return objectTypes
			.stream()
			.map(elementsFindByName::get)
			.map(findByName -> findByName.apply(name))
			.flatMap(i -> i)
			.sorted(getStartWithIgnoreCaseComparator(name))
			.toList();
	}
	
	// ===================== FIND BY NAME ===================== //

	private Stream<EpbsMinimalObjectDTO> findFundByName(String name) {
		return fundRepository.findAllLegalNameIdByLegalNameContaining(name)
				.stream()
				.map(f -> EpbsMinimalObjectUtils.buildMinimalFund(f.getId(), f.getLegalName()));
	}

	private Stream<EpbsMinimalObjectDTO> findSubFundByName(String name) {
		return subFundRepository.findAllLegalNameIdByLegalNameContaining(name)
				.stream()
				.map(sf -> EpbsMinimalObjectUtils.buildMinimalSubFund(sf.getId(), sf.getLegalName()));
	}
	
	private Stream<EpbsMinimalObjectDTO> findSegmentByName(String name) {
		return segmentRepository.findAllNameIdByNameContaining(name)
				.stream()
				.map(seg -> EpbsMinimalObjectUtils.buildMinimalSegment(seg.getId(), seg.getName()));
	}

	private Stream<EpbsMinimalObjectDTO> findNaturalPersonByName(String name) {
		return naturalPersonRepository.findAllFirstNameLastNameIdByFirstNameContainsOrLastNameContains(name, name)
				.stream()
				.map(np -> EpbsMinimalObjectUtils.buildMinimalNaturalPerson(np.getId(), np.getFirstName(), np.getLastName()));
	}

	private Stream<EpbsMinimalObjectDTO> findLegalPersonByName(String name) {
		return legalPersonRepository.findAllLegalNameIdByLegalNameContaining(name)
				.stream()
				.map(lp -> EpbsMinimalObjectUtils.buildMinimalLegalPerson(lp.getId(), lp.getLegalName()));
	}
	
	private Stream<EpbsMinimalObjectDTO> findProjectByName(String name) {
		return projectDescriptionsRepository.findAllNameIdByNameContaining(name)
				.stream()
				.map(p -> EpbsMinimalObjectUtils.buildMinimalProject(p.getId(), p.getName()));
	}
	
	// ===================== FIND BY IDS ===================== //
	
	private Stream<EpbsMinimalObjectDTO> findFundsByIds(List<Integer> fundIds) {
		return fundRepository.findAllLegalNameIdByIdIn(fundIds)
				.stream()
				.map(f -> EpbsMinimalObjectUtils.buildMinimalFund(f.getId(), f.getLegalName()));
	}
	
	private Stream<EpbsMinimalObjectDTO> findSubFundsByIds(List<Integer> subFundIds) {
		return subFundRepository.findAllLegalNameIdByIdIn(subFundIds)
				.stream()
				.map(sf -> EpbsMinimalObjectUtils.buildMinimalSubFund(sf.getId(), sf.getLegalName()));
	}
	
	private Stream<EpbsMinimalObjectDTO> findSegmentsByIds(List<Integer> segmentIds) {
		return segmentRepository.findAllNameIdByIdIn(segmentIds)
				.stream()
				.map(seg -> EpbsMinimalObjectUtils.buildMinimalSegment(seg.getId(), seg.getName()));
	}
	
	private Stream<EpbsMinimalObjectDTO> findNaturalPersonsByIds(List<Integer> naturalPersonIds) {
		return naturalPersonRepository.findAllFirstNameLastNameIdByIdIn(naturalPersonIds)
				.stream()
				.map(np -> EpbsMinimalObjectUtils.buildMinimalNaturalPerson(np.getId(), np.getFirstName(), np.getLastName()));
	}
	
	private Stream<EpbsMinimalObjectDTO> findLegalPersonsByIds(List<Integer> legalPersonIds) {
		return legalPersonRepository.findAllLegalNameIdByIdIn(legalPersonIds)
				.stream()
				.map(lp -> EpbsMinimalObjectUtils.buildMinimalLegalPerson(lp.getId(), lp.getLegalName()));
	}
	
	private Stream<EpbsMinimalObjectDTO> findProjectsByIds(List<Integer> projectIds) {
		return projectDescriptionsRepository.findAllNameIdByIdIn(projectIds)
				.stream()
				.map(p -> EpbsMinimalObjectUtils.buildMinimalProject(p.getId(), p.getName()));
	}

	// ===================== OTHER ===================== //
    
    private List<Integer> getObjectIdsFromElemType(List<EpbsMinimalObjectSearchDTO> epbsMinimalObjectSearchDTO, ElemTypeEnumDTO elemType) {
    	return epbsMinimalObjectSearchDTO.stream()
    			.filter(ro -> elemType.equals(ro.getType()))
    			.map(EpbsMinimalObjectSearchDTO::getId)
    			.map(Integer::valueOf)
    			.toList();
    }
    
    private static Comparator<EpbsMinimalObjectDTO> getStartWithIgnoreCaseComparator(String query) {
		return (obj1, obj2) -> Boolean.compare(StringUtils.startsWithIgnoreCase(obj2.getObjectName(), query),
				StringUtils.startsWithIgnoreCase(obj1.getObjectName(), query));
    }
    
}