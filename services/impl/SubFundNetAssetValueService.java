package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.mappings.RevisionSubFundNetAssetValueMapper;
import com.bdl.epbs_fund_api.mappings.SubFundNetAssetValueMapper;
import com.bdl.epbs_fund_api.mappings.SubFundPreviewLastNetAssetValueMapper;
import com.bdl.epbs_fund_api.model.*;
import com.bdl.epbs_fund_api.model.entities.SubFundNetAssetValue;
import com.bdl.epbs_fund_api.repositories.SubFundNetAssetValueRepository;
import com.bdl.epbs_fund_api.specification.SubFundNetAssetValueSpecification;
import com.bdl.epbs_fund_api.specification.criteria.SubFundNetAssetValueSearchCriteria;
import com.bdl.epbs_fund_api.utils.RevisionUtils;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.data.domain.Sort.Order;
import org.springframework.data.history.Revisions;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class SubFundNetAssetValueService {

	private final SubFundService subFundService;
	private final SubFundNetAssetValueValidatorService subFundNetAssetValueValidatorService;
	
    private final SubFundNetAssetValueRepository subFundNetAssetValueRepository;

    private final SubFundNetAssetValueMapper subFundNetAssetValueMapper;

    private final SubFundPreviewLastNetAssetValueMapper subFundPreviewLastNetAssetValueMapper;

    private final RevisionSubFundNetAssetValueMapper revisionSubFundNetAssetValueMapper;
    
    private static final String VALUE_DATE = "valueDate";
    private static final String SUBFUND_LEGALNAME = "subFund.legalName";

    public Page<SubFundNetAssetValueDTO> getSubFundNetAssetValues(final Integer page, final Integer size, final SubFundNetAssetValueSearchCriteria subFundNavSearch) {
        return subFundNetAssetValueRepository.findAll(
        				SubFundNetAssetValueSpecification.allCriteria(subFundNavSearch.getSubFundId(), subFundNavSearch.getDateFrom(), subFundNavSearch.getDateTo()),
                        PageRequest.of(page, size, Sort.by(VALUE_DATE).descending()))
                .map(subFundNetAssetValueMapper::toDTO);
    }
    
    public SubFundNetAssetValueDTO createSubFundNetAssetValue(final Integer subFundId, final SubFundNetAssetValueCreateDTO subFundNetAssetValueCreate, final Boolean xIgnoreWarning) {
    	SubFundNetAssetValue subFundNavToCreate = subFundNetAssetValueMapper.toEntity(subFundId, subFundNetAssetValueCreate);
    	
    	subFundNetAssetValueValidatorService.validateCreateSubFundNetAssetValue(subFundNavToCreate, xIgnoreWarning);
    	
    	return subFundNetAssetValueMapper.toDTO(subFundNetAssetValueRepository.save(subFundNavToCreate));
    }
    
    public SubFundNetAssetValueDTO updateSubFundNetAssetValue(final Integer subFundNetAssetValueId, final SubFundNetAssetValueUpdateDTO subFundNetAssetValueUpdate, final Boolean xIgnoreWarning) {
    	SubFundNetAssetValue subFundNetAssetValue = getSubFundNetAssetValue(subFundNetAssetValueId);
    	SubFundNetAssetValue subFundNetAssetValueToUpdate = subFundNetAssetValueMapper.toEntity(subFundNetAssetValue, subFundNetAssetValueUpdate);
    	
    	subFundNetAssetValueValidatorService.validateUpdateSubFundNetAssetValue(subFundNetAssetValueToUpdate, xIgnoreWarning);
    	
    	return subFundNetAssetValueMapper.toDTO(subFundNetAssetValueRepository.save(subFundNetAssetValueToUpdate));
    }

	public void deleteSubFundNetAssetValue(final Integer subFundNetAssetValueId) {
		subFundNetAssetValueRepository.deleteById(subFundNetAssetValueId);
	}

    public SubFundNetAssetValueDTO getLastSubFundNetAssetValue(final Integer subFundId) {
        final SubFundNetAssetValueDTO emptyNav = new SubFundNetAssetValueDTO();

        return Objects.isNull(subFundService.getSubFundEntity(subFundId).getAreNavsAuto())
                ? emptyNav
                : subFundNetAssetValueRepository.findFirstBySubFundIdOrderByValueDateDesc(subFundId)
	                .map(subFundNetAssetValueMapper::toDTO)
	                .orElse(emptyNav);
    }

    public Page<SubFundPreviewLastNetAssetValueDTO> getFundLastSubFundNetAssetValues(final Integer page, final Integer size, final Integer fundId, final LocalDate dateTo) {
    	List<Order> orders = List.of(
    			new Order(Direction.DESC, VALUE_DATE),
    			new Order(Direction.ASC, SUBFUND_LEGALNAME));
    	return subFundNetAssetValueRepository.findLatestNavPerSubFundByFundIdAndValueDateLessOrEqual(fundId, dateTo, PageRequest.of(page, size, Sort.by(orders)))
                .map(subFundPreviewLastNetAssetValueMapper::toLastNetAssetValueDTO);
    }

    private SubFundNetAssetValue getSubFundNetAssetValue(final Integer subFundNetAssetValueId) {
    	return subFundNetAssetValueRepository.findById(subFundNetAssetValueId).orElseThrow(() -> new ResourceNotFoundException("could not find subfundnetassetvalue with id :" + subFundNetAssetValueId));
    }

    public List<RevisionSubFundNetAssetValueDTO> getSubFundNetAssetValueRevisions(Integer navId) {
        Revisions<Integer, SubFundNetAssetValue> revisions = subFundNetAssetValueRepository.findRevisions(navId);

        List<RevisionSubFundNetAssetValueDTO> navsRevisions = revisions
                .stream()
                .map(revisionSubFundNetAssetValueMapper::fromEntityToDTO)
                .toList();

        return RevisionUtils.sortRevisionsAndOrganise(
                navsRevisions,
                (r1, r2) -> Integer.compare(r2.getId(), r1.getId()),
                RevisionSubFundNetAssetValueDTO::getAfter,
                RevisionSubFundNetAssetValueDTO::getBefore,
                RevisionSubFundNetAssetValueDTO::setBefore,
                revisionSubFundNetAssetValueMapper);
    }
}
