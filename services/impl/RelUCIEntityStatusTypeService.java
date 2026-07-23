package com.bdl.epbs_fund_api.services.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.types.RelUCIEntityStatusType;
import com.bdl.epbs_fund_api.repositories.RelUCIEntityStatusTypeRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RelUCIEntityStatusTypeService {
	
	@Autowired
	private RelUCIEntityStatusTypeRepository relUCIEntityStatusTypeRepository;
	
	public List<RelUCIEntityStatusType> getAllByUCIEntityId(Integer uciEntityId) {
		return relUCIEntityStatusTypeRepository.getRelUCIEntityStatusTypeByUciEntityIdOrderByStartDateDescIdDesc(uciEntityId);
	}
}
