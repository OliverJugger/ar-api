package com.bdl.epbs_fund_api.repositories.metadata;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.metadata.MasterRecordStorage;

@Repository
public interface MasterRecordStorageRepository extends JpaRepository<MasterRecordStorage, Integer> {

    MasterRecordStorage findByEpbsIdAndEpbsElemTypeIntlId(Integer epbsId, String elemTypeIntlId);

}
