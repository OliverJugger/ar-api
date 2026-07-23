package com.bdl.epbs_fund_api.services.access.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.entities.DataProfile;
import com.bdl.epbs_fund_api.repositories.access.DataProfileRepository;
import com.bdl.epbs_fund_api.services.access.IDataProfileService;

@Service
public class DataProfileService implements IDataProfileService {

	@Autowired
    private DataProfileRepository dataProfileRepository;
	
	public List<Integer> getRelAccessProfileElemEpbsFromDataProfile(List<String> dataProfiles, String elemType) {
		return dataProfileRepository.findAllRelAccessProfileElemEpbsByDataProfileInAndElemType(dataProfiles, elemType);
	}
	
    @Override
    public List<String> getDataProfileIntlIdFromProfileNames(List<String> profileNames) {
        return dataProfileRepository.findByNames(profileNames);
    }

    @Override
    public DataProfile getDataProfileFromIntlId(String intlId) {
        return dataProfileRepository.findByIntlId(intlId);
    }

}
