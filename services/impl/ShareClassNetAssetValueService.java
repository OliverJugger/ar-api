package com.bdl.epbs_fund_api.services.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.ShareClassNetAssetValueMapper;
import com.bdl.epbs_fund_api.model.ShareClassNetAssetValueDTO;
import com.bdl.epbs_fund_api.repositories.ShareClassNetAssetValueRepository;
import com.bdl.epbs_fund_api.specification.ShareClassNetAssetValueSpecification;
import com.bdl.epbs_fund_api.specification.criteria.ShareClassNetAssetValueSearchCriteria;
import com.google.common.collect.Lists;

import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ShareClassNetAssetValueService {

	private static final int MAX_NAV_PARTITION = 1000;
    private static final String VALUE_DATE = "valueDate";

    private final ShareClassNetAssetValueRepository shareClassNetAssetValueRepository;
    private final ShareClassNetAssetValueMapper shareClassNetAssetValueMapper;
	private final EntityManager entityManager;

    public Page<ShareClassNetAssetValueDTO> getShareClassNetAssetValues(final Integer page, final Integer size, final ShareClassNetAssetValueSearchCriteria shareClassNavSearch) {
        return shareClassNetAssetValueRepository.findAll(
                        ShareClassNetAssetValueSpecification.allCriteria(shareClassNavSearch.getShareClassId(), shareClassNavSearch.getDateFrom(), shareClassNavSearch.getDateTo()),
                        PageRequest.of(page, size, Sort.by(VALUE_DATE).descending()))
                .map(shareClassNetAssetValueMapper::toDTO);
    }
    
    @Transactional
	public void updateAllShareClassNavPerShareSF(Map<Integer, BigDecimal> valuesMap) {
		List<Map.Entry<Integer, BigDecimal>> entries = new ArrayList<>(valuesMap.entrySet());
		List<List<Map.Entry<Integer, BigDecimal>>> subSets = Lists.partition(entries, MAX_NAV_PARTITION);
		subSets
			.forEach(entryBatch -> {
				entryBatch
					.forEach(entry -> shareClassNetAssetValueRepository.updateShareClassNavPerShareSF(entry.getKey(), entry.getValue()));
				entityManager.flush();
				entityManager.clear();
			});
	}
    
}
