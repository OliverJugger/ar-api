package com.bdl.epbs_fund_api.repositories;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.bdl.epbs_fund_api.model.entities.ShareClassNetAssetValue;

import jakarta.transaction.Transactional;

public interface ShareClassNetAssetValueRepository extends JpaRepository<ShareClassNetAssetValue, Integer>, JpaSpecificationExecutor<ShareClassNetAssetValue> {

    Optional<ShareClassNetAssetValue> findFirstByShareClassIdOrderByValueDateDesc(Integer shareClassId);

    Optional<ShareClassNetAssetValue> findByShareClassIdAndValueDate(Integer shareClassId, LocalDate valueDate);
    
    List<ShareClassNetAssetValue> findAllByValueDate(LocalDate valueDate);

    @EntityGraph(attributePaths = {
    		"shareClass",
    		"shareClass.currency"
    }) // force fetch for this case (eager loading)
    List<ShareClassNetAssetValue> findAllByShareClassSubFundAreNavsAutoIsTrueAndNavPerShareSCIsNotNullAndNavPerShareSFIsNull();
    
    @Transactional
    @Modifying
    @Query("UPDATE ShareClassNetAssetValue scnav "
        + "SET scnav.navPerShareSF =:newValue "
        + "WHERE scnav.id = :shareClassNavId")
    void updateShareClassNavPerShareSF(@Param("shareClassNavId") Integer shareClassNavId, @Param("newValue") BigDecimal newValue);

}
