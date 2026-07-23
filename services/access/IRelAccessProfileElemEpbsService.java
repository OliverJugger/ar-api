package com.bdl.epbs_fund_api.services.access;

import com.bdl.epbs_fund_api.model.relations.RelAccessProfileElemEpbs;

public interface IRelAccessProfileElemEpbsService {

    RelAccessProfileElemEpbs getByEpbsIdAndElemTypeIntlId(Integer epbsId, String elemTypeIntlId);

    RelAccessProfileElemEpbs insertRelAccessProfileElemEpbs(RelAccessProfileElemEpbs relAccessProfileElemEpbs);

}
