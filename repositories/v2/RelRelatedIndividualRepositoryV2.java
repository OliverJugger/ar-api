package com.bdl.epbs_fund_api.repositories.v2;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.repository.history.RevisionRepository;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.relations.v2.RelRelatedIndividualV2;
import com.bdl.epbs_fund_api.services.access.HasAccessData;

public interface RelRelatedIndividualRepositoryV2 extends JpaRepository<RelRelatedIndividualV2, Integer>, JpaSpecificationExecutor<RelRelatedIndividualV2>, RevisionRepository<RelRelatedIndividualV2, Integer, Integer> {

    @HasAccessData(elemTypeIntlId = Constants.INTL_ID_ELEM_REL_IND)
    Optional<RelRelatedIndividualV2> findById(Integer id);

}