package com.bdl.epbs_fund_api.services;

import com.bdl.epbs_fund_api.authentication.UserContext;
import com.bdl.epbs_fund_api.authentication.access.impl.DataAccessService;
import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.services.metadata.impl.MasterRecordStorageService;
import com.bdl.epbs_fund_api.utils.ValidationUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Service
public class TechnicalAccessService {

    private final MasterRecordStorageService masterRecordStorageService;
    private final DataAccessService dataAccessService;

    public List<String> getUserProfilesIntId() {
        return this.dataAccessService.getProfilesIntlId(UserContext.getCurrentUser());
    }
    
    public final void updateTechnicalTables(Integer uid, String intlIdElement) {
        this.updateTechnicalTables(uid, intlIdElement, Constants.INTL_ID_EPBS_PROFILE_NA);
    }

    public void updateTechnicalTables(Integer uid, String intlIdElement, String profile) {
        ValidationUtils.validateIntlIdElement(intlIdElement);
        ValidationUtils.validateAccessProfile(profile);

        masterRecordStorageService.create(uid, intlIdElement);
        dataAccessService.insertNewRelAccessProfileElemEpbs(uid, intlIdElement, profile);
    }
}
