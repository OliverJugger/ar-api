package com.bdl.epbs_fund_api.repositories.access;

import com.bdl.epbs_fund_api.model.relations.RelAccessProfileElemEpbs;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface RelAccessProfileElemEpbsRepository extends JpaRepository<RelAccessProfileElemEpbs, Integer> {

    @Query(value = "SELECT rAPEE.* " +
            "FROM Access.RelAccessProfileElemEpbs rAPEE " +
            "INNER JOIN MetaData.ElemType ET ON rAPEE.EpbsElemTypeID = ET.ElemTypeID " +
            "WHERE rAPEE.epbsID = :epbsId and  ET.intlId = :elemTypeIntlId", nativeQuery = true)
    RelAccessProfileElemEpbs findByEpbsIdAndElemTypeIntlId(@Param("epbsId") Integer epbsId, @Param("elemTypeIntlId") String elemTypeIntlId);

}