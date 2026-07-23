package com.bdl.epbs_fund_api.services.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.StaticDataLabelMapper;
import com.bdl.epbs_fund_api.model.StaticDataLabelDTO;
import com.bdl.epbs_fund_api.repositories.IStaticDataRepository;
import com.bdl.epbs_fund_api.services.IStaticDataService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class StaticDataService implements IStaticDataService {

    private final IStaticDataRepository staticDataRepository;
    
    private final StaticDataLabelMapper staticDataLabelMapper;

	@Override
	public List<StaticDataLabelDTO> getAllStaticDataTypeByIntlId(String intlId) {
		return staticDataLabelMapper.mapFromStaticDataLabel(staticDataRepository.findByDataTypeIntlId(intlId));
	}
	
	@Override
	public StaticDataLabelDTO getByIntlId(String intlId) {
		return staticDataLabelMapper.mapFromStaticDataLabel(staticDataRepository.findByIntlId(intlId));
	}
}
