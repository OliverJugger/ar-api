package com.bdl.epbs_fund_api.repositories.navs;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.navs.KeyFigureInvestran;

@Repository
public interface KeyFiguresInvestranRepository extends JpaRepository<KeyFigureInvestran, Integer> {

	List<KeyFigureInvestran> findAllByValuationDate(LocalDate date);
	
	Optional<KeyFigureInvestran> findByValuationDateAndSubFundCodeAndShareCodeAndCcyNavShare(LocalDate date, String subFundFundAccountingCode, String shareCode, String shareClassCurrency);

}
