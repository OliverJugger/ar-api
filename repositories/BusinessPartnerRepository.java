package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.entities.BusinessPartner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BusinessPartnerRepository extends JpaRepository<BusinessPartner, Integer> {

    void deleteByLegalPersonId(Integer id);

}
