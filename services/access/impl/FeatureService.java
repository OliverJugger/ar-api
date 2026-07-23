package com.bdl.epbs_fund_api.services.access.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.access.Feature;
import com.bdl.epbs_fund_api.repositories.access.FeatureRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class FeatureService {
	
	private final FeatureRepository featureRepository;

	public List<Feature> getAll() {
		return featureRepository.findAll();
	}
	
	public List<Feature> getAllByIntlId(String inltId) {
		return featureRepository.findAllByIntlIdContaining(inltId);
	}
	
	public List<Feature> putFeatures(List<Feature> features) {
		return featureRepository.saveAll(features);
	}
	
}
