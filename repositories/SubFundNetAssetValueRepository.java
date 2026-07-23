package com.bdl.epbs_fund_api.repositories;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.history.Revisions;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.history.RevisionRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.entities.SubFundNetAssetValue;

@Repository
public interface SubFundNetAssetValueRepository extends JpaRepository<SubFundNetAssetValue, Integer>, JpaSpecificationExecutor<SubFundNetAssetValue>, RevisionRepository<SubFundNetAssetValue, Integer, Integer> {

    Optional<SubFundNetAssetValue> findFirstBySubFundIdAndValueDateBeforeOrderByValueDateDesc(Integer subFundId, LocalDate valueDate);
    
    Optional<SubFundNetAssetValue> findFirstBySubFundIdOrderByValueDateDesc(Integer subFundId);

    Optional<SubFundNetAssetValue> findBySubFundIdAndValueDate(Integer subFundId, LocalDate valueDate);

    List<SubFundNetAssetValue> findAllBySubFundAreNavsAutoIsFalse();

    List<SubFundNetAssetValue> findAllBySubFundAreNavsAutoIsFalseAndNavBankIsNull();

    @Query("""
        SELECT nav 
        FROM SubFundNetAssetValue nav
        WHERE nav.subFund.fund.fundId = :fundId
        AND nav.valueDate = (
            SELECT MAX(innerNav.valueDate)
            FROM SubFundNetAssetValue innerNav
            WHERE innerNav.subFund = nav.subFund
            AND innerNav.valueDate <= :dateTo
        )
        AND nav.subFund.id NOT IN (
    	    SELECT relUciStatus.uciEntity.id
    	    FROM RelUCIEntityStatusType relUciStatus
    	    WHERE relUciStatus.statusType.intlId = 'inactive'
    	    AND relUciStatus.startDate < :#{#dateTo.atStartOfDay()}
    	)
    """)
    Page<SubFundNetAssetValue> findLatestNavPerSubFundByFundIdAndValueDateLessOrEqual(@Param("fundId") Integer fundId, @Param("dateTo") LocalDate dateTo, Pageable pageable);

    Revisions<Integer, SubFundNetAssetValue> findRevisionsBySubFund_Id(Integer subFundId);
}