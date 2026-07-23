package com.bdl.epbs_fund_api.services.impl;

import java.util.List;

import com.bdl.epbs_fund_api.model.entities.Country;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.CountryMapper;
import com.bdl.epbs_fund_api.model.CountryDTO;
import com.bdl.epbs_fund_api.repositories.CountryRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CountryService {

	private final CountryMapper countryMapper;

	private final CountryRepository countryRepository;

	public List<CountryDTO> getAllCountries() {
		return countryMapper.mapFromCountry(countryRepository.findAll());
	}

	public Country findByIsocode3(String isocode3) {
		return countryRepository.findByIsocode3(isocode3).orElseThrow(() -> new ResourceNotFoundException("could not find entity with code : " + isocode3));
	}
}
