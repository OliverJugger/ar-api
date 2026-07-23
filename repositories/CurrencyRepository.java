package com.bdl.epbs_fund_api.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.entities.Currency;

@Repository
public interface CurrencyRepository extends JpaRepository<Currency, Integer> {
	
	Optional<Currency> findByName(String name);
}
