package com.bdl.epbs_fund_api.services.access.impl;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.relations.RelAccessProfileElemEpbs;
import com.bdl.epbs_fund_api.repositories.access.RelAccessProfileElemEpbsRepository;
import com.bdl.epbs_fund_api.services.access.IRelAccessProfileElemEpbsService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RelAccessProfileElemEpbsService implements IRelAccessProfileElemEpbsService {

    private final RelAccessProfileElemEpbsRepository relAccessProfileElemEpbsRepository;

    @Override
    public RelAccessProfileElemEpbs getByEpbsIdAndElemTypeIntlId(Integer epbsId, String elemTypeIntlId) {
        return relAccessProfileElemEpbsRepository.findByEpbsIdAndElemTypeIntlId(epbsId, elemTypeIntlId);
    }

    @Override
    public RelAccessProfileElemEpbs insertRelAccessProfileElemEpbs(RelAccessProfileElemEpbs relAccessProfileElemEpbs) {
        return relAccessProfileElemEpbsRepository.save(relAccessProfileElemEpbs);
    }

}
