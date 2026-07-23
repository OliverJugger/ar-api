package com.bdl.epbs_fund_api.services.nav;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import com.bdl.epbs_fund_api.mappings.navs.ExchangeRateMapper;
import com.bdl.epbs_fund_api.model.ExchangeRateDTO;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.CurrencyEnumDTO;
import com.bdl.epbs_fund_api.model.entities.Currency;
import com.bdl.epbs_fund_api.repositories.navs.ExchangeRateRepository;
import com.bdl.epbs_fund_api.services.impl.CurrencyService;

import lombok.AllArgsConstructor;

/**
 * Warning : xRate values are reversed in DB (1.03 -> 1/1.03)
 *
 */
@Service
@AllArgsConstructor
public class ExchangeRateService {

	private final CurrencyService currencyService;
	private final ExchangeRateRepository exchangeRateRepository;
	private final ExchangeRateMapper exchangeRateMapper;
	
	private static final MathContext ROUND_15_EVEN = new MathContext(15, RoundingMode.HALF_EVEN);
	private static final CurrencyEnumDTO PIVOT_EUR = CurrencyEnumDTO.EUR;
	private static final CurrencyEnumDTO PIVOT_USD = CurrencyEnumDTO.USD;

	@Transactional
	public List<ExchangeRateDTO> insertExchangeRates(List<ExchangeRateDTO> exchangeRateDTOList) {
		return exchangeRateMapper.toDTO(
				exchangeRateRepository.saveAll(
						exchangeRateMapper.toEntity(exchangeRateDTOList)));
	}
	
	public Optional<BigDecimal> computeExchangeV2(BigDecimal value, LocalDate date, CurrencyEnumDTO from, CurrencyEnumDTO to) {
		if(from.equals(to)) {
			return Optional.ofNullable(value);
		}

		Currency fromCurrency = currencyService.getCurrencyByName(from.getValue());
		Currency toCurrency = currencyService.getCurrencyByName(to.getValue());
		
		return getComputedExchangeRateByDateCurrencyAndFixCurrency(date, fromCurrency, toCurrency)
				.or(() -> getComputedExchangeRateByDateCurrencyAndFixCurrencyReversed(date, fromCurrency, toCurrency))
				.or(() -> getComputedExchangeRateByDateCurrencyAndFixCurrencyPivot(date, fromCurrency, toCurrency))
				.map(exchange -> value.multiply(exchange, ROUND_15_EVEN));
	}
	
	public Optional<BigDecimal> getComputedExchangeRateByDateCurrencyAndFixCurrency(LocalDate date, CurrencyEnumDTO from, CurrencyEnumDTO to) {
		Currency fromCurrency = currencyService.getCurrencyByName(from.getValue());
		Currency toCurrency = currencyService.getCurrencyByName(to.getValue());
		return Optional.ofNullable(exchangeRateRepository.findByValueDateAndCurrencyAndFixCurrency(date, fromCurrency, toCurrency))
				.map(xRateQuotity -> {
					BigDecimal unitRate = xRateQuotity.getXRate().divide(xRateQuotity.getQuotity());
					return new BigDecimal(1).divide(unitRate, ROUND_15_EVEN);
				});
	}
	
	private Optional<BigDecimal> getComputedExchangeRateByDateCurrencyAndFixCurrency(LocalDate date, Currency fromCurrency, Currency toCurrency) {
		return Optional.ofNullable(exchangeRateRepository.findByValueDateAndCurrencyAndFixCurrency(date, fromCurrency, toCurrency))
				.map(xRateQuotity -> {
					BigDecimal unitRate = xRateQuotity.getXRate().divide(xRateQuotity.getQuotity());
					return new BigDecimal(1).divide(unitRate, ROUND_15_EVEN);
				});
	}

	private Optional<BigDecimal> getComputedExchangeRateByDateCurrencyAndFixCurrencyReversed(LocalDate date, Currency fromCurrency, Currency toCurrency) {
		return Optional.ofNullable(exchangeRateRepository.findByValueDateAndCurrencyAndFixCurrency(date, toCurrency, fromCurrency))
				.map(xRateQuotity ->  xRateQuotity.getXRate().divide(xRateQuotity.getQuotity()));
	}
	
	private Optional<BigDecimal> getComputedExchangeRateByDateCurrencyAndFixCurrencyPivot(LocalDate date, Currency fromCurrency, Currency toCurrency) {
		Currency currencyPivotEur = currencyService.getCurrencyByName(PIVOT_EUR.getValue());
		Currency currencyPivotUsd = currencyService.getCurrencyByName(PIVOT_USD.getValue());
		return getComputedExchangeRateByDateCurrencyAndFixCurrency(date, fromCurrency, currencyPivotEur)
					.map(exchangeFromFromToPivotEur -> 
						 getComputedExchangeRateByDateCurrencyAndFixCurrencyReversed(date, currencyPivotEur, toCurrency)
								.map(exchangeFromPivotEurToTo -> exchangeFromFromToPivotEur.multiply(exchangeFromPivotEurToTo, ROUND_15_EVEN)))
					.orElse(
                            getComputedExchangeRateByDateCurrencyAndFixCurrency(date, fromCurrency, currencyPivotUsd)
									.flatMap(exchangeFromFromToPivotUsd -> getComputedExchangeRateByDateCurrencyAndFixCurrencyReversed(date, currencyPivotUsd, toCurrency)
                                    .map(exchangeFromPivotUsdToTo -> exchangeFromFromToPivotUsd.multiply(exchangeFromPivotUsdToTo, ROUND_15_EVEN))));
	}
}
