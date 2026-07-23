package com.bdl.epbs_fund_api.repositories.access;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.entities.DataProfile;



@Repository
public interface DataProfileRepository extends JpaRepository<DataProfile, Integer> {

    @Query("SELECT dp.intlId "
    		+ "FROM DataProfile dp "
    		+ "WHERE dp.name IN :profilesName")
    List<String> findByNames(@Param("profilesName")List<String> profilesName);

    DataProfile findByIntlId(String intlId);

	@Query("SELECT rAPEE.epbsId "
			+ "FROM RelAccessProfileElemEpbs rAPEE " + 
			"  WHERE rAPEE.epbsElemType.intlId = :elemType " + 
			"  AND rAPEE.dataProfile.intlId IN :dataProfilesIntlIdUser")
    //@Cacheable(cacheNames = "relAccessProfileElemEpbsByDataProfileInAndElemType") TODO : reactiver quand EPBS-3613 DONE
    List<Integer> findAllRelAccessProfileElemEpbsByDataProfileInAndElemType(
    		@Param("dataProfilesIntlIdUser") List<String> dataProfiles,
    		@Param("elemType") String elemType);

}
