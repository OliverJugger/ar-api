package com.bdl.epbs_fund_api.services.access;

import com.bdl.epbs_fund_api.model.entities.DataProfile;

import java.util.List;

public interface IDataProfileService {

    List<String> getDataProfileIntlIdFromProfileNames(List<String> profileNames);

    DataProfile getDataProfileFromIntlId(String intlId);

}
