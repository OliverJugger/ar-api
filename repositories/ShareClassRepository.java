package com.bdl.epbs_fund_api.repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.entities.ShareClass;

@Repository
public interface ShareClassRepository extends JpaRepository<ShareClass, Integer> {
	
	List<ShareClass> findAllBySubFundId(Integer subFundId);
	
	Optional<ShareClass> findBySubFundIdAndShareCodeAndCurrencyName(Integer subFundId, String shareCode, String currencyName);

}
