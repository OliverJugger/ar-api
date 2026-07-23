package com.bdl.epbs_fund_api.services.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.relations.RelDelegation;
import com.bdl.epbs_fund_api.repositories.RelDelegationRepository;

@Service
public class RelRelatedEntityDelegationService {

	@Autowired
	private RelDelegationRepository relDelegationRepository;
	
	public List<RelDelegation> getAllByRelatedEntityId(Integer relatedEntityId) {
		return relDelegationRepository.getRelDelegationByRelRelatedEntityId(relatedEntityId);
	}
	
}
