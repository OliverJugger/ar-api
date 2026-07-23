package com.bdl.epbs_fund_api.services.scheduler;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.authentication.UserContext;
import com.bdl.epbs_fund_api.mappings.SubFundNetAssetValueMapper;
import com.bdl.epbs_fund_api.model.CurrencyEnumDTO;
import com.bdl.epbs_fund_api.model.SubFundNetAssetValueAuditedDTO;
import com.bdl.epbs_fund_api.model.entities.ShareClassNetAssetValue;
import com.bdl.epbs_fund_api.model.entities.SubFundNetAssetValue;
import com.bdl.epbs_fund_api.repositories.ShareClassNetAssetValueRepository;
import com.bdl.epbs_fund_api.repositories.SubFundNetAssetValueRepository;
import com.bdl.epbs_fund_api.repositories.SubFundRepository;
import com.bdl.epbs_fund_api.services.impl.ShareClassNetAssetValueService;
import com.bdl.epbs_fund_api.services.nav.ExchangeRateService;
import com.bdl.epbs_fund_api.utils.RevisionUtils;

import lombok.extern.log4j.Log4j2;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;

@Log4j2
@Component
public class SchedulerAuditNetAssetValue {

	// Default value will be false
	@Value("${epbs.scheduler.audit.navsf.enable:false}")
	private boolean isEnabledScheduler;
	
	@Value("${epbs.scheduler.audit.user}")
	private String tecUser;

	@Autowired
	private ExchangeRateService exchangeRateService;

	@Autowired
    private SubFundNetAssetValueRepository subFundNetAssetValueRepository;

	@Autowired
    private ShareClassNetAssetValueRepository shareClassNetAssetValueRepository;

	@Autowired
    private SubFundRepository subFundRepository;

	@Autowired
    private SubFundNetAssetValueMapper subFundNetAssetValueMapper;

	@Autowired
	private ShareClassNetAssetValueService shareClassNetAssetValueService;

	@Autowired
	private CacheManager cacheManager;
	
	private static final String XRATE_CACHE = "findByValueDateAndCurrencyAndFixCurrency_cache";
	private static final String SUBFUND_CURRENCY_CACHE = "findSubFundCurrencyNameById_cache";
	private static final String SUBFUND_FUND_CURRENCY_CACHE = "findSubFundFundCurrencyNameById_cache";
	private static final String CURRENCY_CACHE = "getCurrencyByName_cache";

	@Scheduled(cron = "${epbs.scheduler.audit.navsf.cron}")
    @SchedulerLock(name = "RoutineSynchroAuditNavSF", lockAtLeastFor = "10m", lockAtMostFor = "10m")
	public void executeSynchroJob() {
		log.info("Scheduler.executeSynchroAuditJob start");
		if (isEnabledScheduler) {
			log.info("Scheduler.scheduledJob is enabled, processing...");

			UserContext.setCurrentUser(Map.of("sub", tecUser));
			
			synchronizeSubFundNetAssetValuesWithLastRevision();
			
			recomputeExchangeSubFundNetAssetValues();
			recomputeExchangeShareClassNetAssetValues();
			
		}
	}
	
    private void synchronizeSubFundNetAssetValuesWithLastRevision() {
        List<Integer> desynchronizedSubFundNetAssetValuesIds = subFundNetAssetValueRepository.findAllBySubFundAreNavsAutoIsFalse()
                .stream()
                .filter(subFundNav ->
                	subFundNetAssetValueRepository.findLastChangeRevision(subFundNav.getId())
                                .map(subFundNavLastAudit -> {
                                    SubFundNetAssetValueAuditedDTO subFundNavLastAuditValue = subFundNetAssetValueMapper.toAuditDTO(subFundNavLastAudit.getEntity());
                                    SubFundNetAssetValueAuditedDTO subFundNavActualValue = subFundNetAssetValueMapper.toAuditDTO(subFundNav);
                                    return !subFundNetAssetValueMapper.toAuditedEquals(subFundNavLastAuditValue)
                                            .equals(subFundNetAssetValueMapper.toAuditedEquals(subFundNavActualValue));
                                })
                                .orElseGet(() -> true)
                )
                .map(SubFundNetAssetValue::getId)
                .toList();

        if(!CollectionUtils.isEmpty(desynchronizedSubFundNetAssetValuesIds)) {
            List<SubFundNetAssetValue> subFundNavForceAudits = subFundNetAssetValueRepository.findAllById(desynchronizedSubFundNetAssetValuesIds)
                    .stream()
                    .map(initialSubFundNav -> {
                    	initialSubFundNav.setForceAuditVersion(RevisionUtils.incrementAuditVersion(initialSubFundNav.getForceAuditVersion()));
                        return initialSubFundNav;
                    })
                    .toList();
            subFundNetAssetValueRepository.saveAll(subFundNavForceAudits);
        }
    }
    
	private void recomputeExchangeSubFundNetAssetValues() {
    	List<SubFundNetAssetValue> subFundNetAssetValuesToUpdate = subFundNetAssetValueRepository.findAllBySubFundAreNavsAutoIsFalseAndNavBankIsNull()
    		.stream()
    		.map(subFundNetAssetValue -> {
    			LocalDate valueDate = subFundNetAssetValue.getValueDate();
    			Integer subFundId = subFundNetAssetValue.getSubFund().getId();
    			CurrencyEnumDTO subFundCurrency = CurrencyEnumDTO.fromValue(subFundRepository.findSubFundCurrencyNameById(subFundId).getCurrencyName());
    			CurrencyEnumDTO fundCurrency = CurrencyEnumDTO.fromValue(subFundRepository.findSubFundFundCurrencyNameById(subFundId).getFundCurrencyName());
    			
	        	subFundNetAssetValue.setNavF(
	        			exchangeRateService
	        				.computeExchangeV2(subFundNetAssetValue.getNavSF(), valueDate, subFundCurrency, fundCurrency)
	        				.orElse(null));
	        	
	        	subFundNetAssetValue.setNavBank(
	        			exchangeRateService
	        				.computeExchangeV2(subFundNetAssetValue.getNavSF(), valueDate, subFundCurrency, CurrencyEnumDTO.EUR)
	        				.orElse(null));
    	    	
    	    	return subFundNetAssetValue;
    		})
    		.toList();
    	
    	subFundNetAssetValueRepository.saveAll(subFundNetAssetValuesToUpdate);
    }
	
	private void recomputeExchangeShareClassNetAssetValues() {
		Map<Integer, BigDecimal> navPerShareSFs = findExchangeNavPerShareFromSCToSF();
		clearCaches();
		shareClassNetAssetValueService.updateAllShareClassNavPerShareSF(navPerShareSFs);
	}

	private Map<Integer, BigDecimal> findExchangeNavPerShareFromSCToSF() {
		 return shareClassNetAssetValueRepository.findAllByShareClassSubFundAreNavsAutoIsTrueAndNavPerShareSCIsNotNullAndNavPerShareSFIsNull()
    		.stream()    	
    		.map(shareClassNetAssetValueToUpdate -> {
    			LocalDate valueDate = shareClassNetAssetValueToUpdate.getValueDate();
    			Integer subFundId = shareClassNetAssetValueToUpdate.getShareClass().getSubFund().getId();
    			CurrencyEnumDTO shareClassCurrency = CurrencyEnumDTO.fromValue(shareClassNetAssetValueToUpdate.getShareClass().getCurrency().getName());
    			CurrencyEnumDTO subFundCurrency = CurrencyEnumDTO.fromValue(subFundRepository.findSubFundCurrencyNameById(subFundId).getCurrencyName());
    			
    			shareClassNetAssetValueToUpdate.setNavPerShareSF(
	        			exchangeRateService
	        				.computeExchangeV2(shareClassNetAssetValueToUpdate.getNavPerShareSC(), valueDate, shareClassCurrency, subFundCurrency)
	        				.orElse(null));
    	    	
    	    	return shareClassNetAssetValueToUpdate;
    		})
    		.filter(shareClassNav -> Objects.nonNull(shareClassNav.getId()) && Objects.nonNull(shareClassNav.getNavPerShareSF()))
			.collect(Collectors.toMap(ShareClassNetAssetValue::getId, ShareClassNetAssetValue::getNavPerShareSF));
    }
	
	private void clearCaches() {
		Optional.ofNullable(cacheManager.getCache(XRATE_CACHE)).ifPresent(Cache::clear);
		Optional.ofNullable(cacheManager.getCache(SUBFUND_CURRENCY_CACHE)).ifPresent(Cache::clear);
		Optional.ofNullable(cacheManager.getCache(SUBFUND_FUND_CURRENCY_CACHE)).ifPresent(Cache::clear);
		Optional.ofNullable(cacheManager.getCache(CURRENCY_CACHE)).ifPresent(Cache::clear);
	}
	
}
