package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.entities.LegalPerson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface IPersonRepository extends JpaRepository<LegalPerson, Integer> {

    @Query(nativeQuery = true, value = " Select T.PersonID  from (Select PersonID, FundID as uciEntityId from MDLePBS.Fund UNION Select PersonID, SubFundID as uciEntityId from MDLePBS.SubFund) T WHERE T.uciEntityId = :uciEntityId ")
    String getPersonIdByUCIEntityId(@Param("uciEntityId") Integer uciEntityId);
}