package com.bdl.epbs_fund_api.services.metadata.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.metadata.SourceSystem;
import com.bdl.epbs_fund_api.repositories.metadata.SourceSystemRepository;

@Service
public class SourceSystemService {

	@Autowired
	private SourceSystemRepository sourceSystemRepository;
	
	public SourceSystem getSourceSystemByIntlId(String intlId) {
		return sourceSystemRepository.findByIntlId(intlId);
	}
}
