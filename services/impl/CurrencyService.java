package com.bdl.epbs_fund_api.services.impl;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.CurrencyMapper;
import com.bdl.epbs_fund_api.model.CurrencyDTO;
import com.bdl.epbs_fund_api.model.entities.Currency;
import com.bdl.epbs_fund_api.repositories.CurrencyRepository;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CurrencyService {

	private final CurrencyMapper currencyMapper;

	private final CurrencyRepository currencyRepository;

	public List<CurrencyDTO> getAllCurrency() {
		return currencyMapper.mapFromCurrency(currencyRepository.findAll());
	}

    @Cacheable(cacheNames = "getCurrencyByName_cache")
	public Currency getCurrencyByName(String name) {
		return currencyRepository.findByName(name).orElseThrow(() -> new ResourceNotFoundException("could not find entity with name : " + name));
	}
}