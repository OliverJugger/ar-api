package com.bdl.epbs_fund_api.services.impl;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.ShareClassMapper;
import com.bdl.epbs_fund_api.model.CurrencyEnumDTO;
import com.bdl.epbs_fund_api.model.ShareClassDTO;
import com.bdl.epbs_fund_api.model.entities.ShareClass;
import com.bdl.epbs_fund_api.repositories.ShareClassRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ShareClassService {

	private final ShareClassMapper shareClassMapper;
	
	private final ShareClassRepository shareClassRepository;
	
	public List<ShareClassDTO> findAllBySubFundId(Integer subFundId) {
		List<ShareClass> shareClasses = shareClassRepository.findAllBySubFundId(subFundId);
		return shareClassMapper.toDTO(shareClasses);
	}
	
	public ShareClassDTO findById(Integer shareClassId) {
		return shareClassRepository.findById(shareClassId).map(shareClassMapper::toDTO).orElse(null);
	}
	
	public Optional<ShareClass> getShareClassBySubFundIdAndShareCodeAndCurrencyName(Integer subFundId, String shareCode, CurrencyEnumDTO currency) {
		return shareClassRepository.findBySubFundIdAndShareCodeAndCurrencyName(subFundId, shareCode, currency.getValue());
	}

}
