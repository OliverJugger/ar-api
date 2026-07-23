package com.bdl.epbs_fund_api.services;

import java.util.List;

import com.bdl.epbs_fund_api.model.StaticDataLabelDTO;

public interface IStaticDataService {
    List<StaticDataLabelDTO> getAllStaticDataTypeByIntlId(String intlId);
    StaticDataLabelDTO getByIntlId(String intlId);
}
