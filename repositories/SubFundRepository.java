package com.bdl.epbs_fund_api.repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.history.RevisionRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.services.access.HasAccessData;

import jakarta.transaction.Transactional;

@Repository
public interface SubFundRepository extends JpaRepository<SubFund, Integer>, JpaSpecificationExecutor<SubFund>, RevisionRepository<SubFund, Integer, Integer> {

	@HasAccessData(elemTypeIntlId = Constants.INTL_ID_ELEM_SUBFUND)
	Optional<SubFund> findById(Integer id);
	
	Optional<SubFund> findLegalNameById(Integer id);
	
	@Query("SELECT subfund "
			+ "FROM SubFund subfund "
			+ "WHERE subfund.id = (SELECT subFundId FROM Segment where id = :segmentId) ")
	@HasAccessData(elemTypeIntlId = Constants.INTL_ID_ELEM_SUBFUND)
	Optional<SubFund> findBySegmentId(@Param("segmentId") Integer segmentId);
	
	@Query("SELECT DISTINCT subfund from SubFund subfund" +
			" INNER JOIN subfund.relAccessProfileElemEpbs rAPEE" +
			" WHERE subfund.id IN (" +
				" SELECT DISTINCT subfund2.id " +
				" FROM SubFund subfund2" +
				" INNER JOIN RelUCILegalPerson relUCILegalPerson" +
				" ON (subfund2.id = relUCILegalPerson.uciEntity.id " +
					" OR subfund2.fund.fundId = relUCILegalPerson.uciEntity.id )" +
				" INNER JOIN RelRelatedEntity relRelatedEntity" +
				" ON relRelatedEntity.relUciLegalPerson.id = relUCILegalPerson.id" +
				" WHERE relRelatedEntity.id = :relRelatedEntityId)" +
			" AND rAPEE.dataProfile.intlId in :dataProfilesIntlIdUser")
	List<SubFund> findByRelationFOrSFId(
			@Param("relRelatedEntityId") Integer relRelatedEntityId,
			@Param("dataProfilesIntlIdUser") List<String> dataProfilesIntlIdUser);
	
	// /!\ WE HAVE NO CHOICE TO USE UPDATE BECAUSE OF AUDIT /!\
	@Modifying
	@Query(value = "UPDATE MDLePBS.SubFund SET TaskUID = :taskUid WHERE SubFundID = :subFundId", nativeQuery = true)
	@Transactional
	void linkTask(@Param("subFundId") Integer subFundId, @Param("taskUid") String taskUid);

	// /!\ WE HAVE NO CHOICE TO USE UPDATE BECAUSE OF AUDIT /!\
	@Modifying
	@Query(value = "UPDATE MDLePBS.SubFund "
	    + "SET TaskUID = NULL "
	    + "WHERE SubFundID = :subFundId", nativeQuery = true)
	@Transactional
	void unlinkTask(@Param("subFundId") Integer subFundId);

    // FOR EPBS LIGHT OBJECTS (old RELATED OBJECTS) //
	interface SubFundLegalNameId {
		String getId();
		String getLegalName();
	}
	List<SubFundLegalNameId> findAllLegalNameIdByIdIn(List<Integer> ids);
	List<SubFundLegalNameId> findAllLegalNameIdByLegalNameContaining(String legalName);
	
	List<SubFund> findAllByFundAccountingCodeIn(List<String> fundAccountingCode);

	interface SubFundCurrencyName {
		String getCurrencyName();
	}
    @Cacheable(cacheNames = "findSubFundCurrencyNameById_cache")
	SubFundCurrencyName findSubFundCurrencyNameById(Integer id);
    
    interface SubFundFundCurrencyName {
		String getFundCurrencyName();
	}
    @Cacheable(cacheNames = "findSubFundFundCurrencyNameById_cache")
    SubFundFundCurrencyName findSubFundFundCurrencyNameById(Integer id);


}