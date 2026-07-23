package com.bdl.epbs_fund_api.repositories.navs;

import java.time.LocalDate;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.entities.Currency;
import com.bdl.epbs_fund_api.model.navs.ExchangeRate;

@Repository
public interface ExchangeRateRepository extends JpaRepository<ExchangeRate, Integer> {

    @Cacheable(cacheNames = "findByValueDateAndCurrencyAndFixCurrency_cache")
    ExchangeRate findByValueDateAndCurrencyAndFixCurrency(LocalDate valueDate, Currency fromCurrency, Currency toFixCurrency);

}
