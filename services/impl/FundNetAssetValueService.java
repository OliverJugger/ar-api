package com.bdl.epbs_fund_api.services.impl;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Objects;
import java.util.function.Predicate;

import org.apache.commons.collections.CollectionUtils;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.exception.SubFundNetAssetValueComputeException;
import com.bdl.epbs_fund_api.mappings.SubFundPreviewLastNetAssetValueMapper;
import com.bdl.epbs_fund_api.model.FundNetAssetValueDTO;
import com.bdl.epbs_fund_api.model.NavCurrencyTypeDTO;
import com.bdl.epbs_fund_api.model.SubFundV2NAVPreviewDTO;
import com.bdl.epbs_fund_api.model.entities.SubFundNetAssetValue;
import com.bdl.epbs_fund_api.repositories.SubFundNetAssetValueRepository;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class FundNetAssetValueService {

    private final SubFundNetAssetValueRepository subFundNetAssetValueRepository;
    private final SubFundPreviewLastNetAssetValueMapper mapper;
    
    private static final Predicate<SubFundNetAssetValue> MISS_NAV_F = nav -> Objects.isNull(nav.getNavF()) || Objects.isNull(nav.getSubscriptionValF()) || Objects.isNull(nav.getRedemptionValF());
    private static final Predicate<SubFundNetAssetValue> MISS_NAV_BANK = nav -> Objects.isNull(nav.getNavBank()) || Objects.isNull(nav.getSubscriptionValBank()) || Objects.isNull(nav.getRedemptionValBank());
    
    public FundNetAssetValueDTO getFundNetAssetValues(Integer fundId, NavCurrencyTypeDTO type, LocalDate dateTo) {
        List<SubFundNetAssetValue> subFundNavs = subFundNetAssetValueRepository
                .findLatestNavPerSubFundByFundIdAndValueDateLessOrEqual(fundId, dateTo, PageRequest.ofSize(Integer.MAX_VALUE))
                .toList();
        
        return NavCurrencyTypeDTO.BANK.equals(type) 
        		? calculateBankNav(subFundNavs)
        		: calculateFundNav(subFundNavs);
    }

    private FundNetAssetValueDTO calculateBankNav(List<SubFundNetAssetValue> subFundNavs) {
    	List<SubFundV2NAVPreviewDTO> missingNavsBank = getMissingNavs(subFundNavs, MISS_NAV_BANK);
        
        if(CollectionUtils.isNotEmpty(missingNavsBank)) {
        	throw new SubFundNetAssetValueComputeException(missingNavsBank);
    	}
        
        FundNetAssetValueBuilder fundNav = new FundNetAssetValueBuilder();

        subFundNavs.forEach(nav -> {
            fundNav.addNetAssetValue(nav.getNavBank());
            fundNav.addSubscription(nav.getSubscriptionValBank());
            fundNav.addRedemption(nav.getRedemptionValBank());
        });

        return fundNav.build();
    }

    private FundNetAssetValueDTO calculateFundNav(List<SubFundNetAssetValue> subFundNavs) {
    	
        List<SubFundV2NAVPreviewDTO> missingNavsF = getMissingNavs(subFundNavs, MISS_NAV_F);
        
        if(CollectionUtils.isNotEmpty(missingNavsF)) {
        	throw new SubFundNetAssetValueComputeException(missingNavsF);
    	}

        FundNetAssetValueBuilder fundNav = new FundNetAssetValueBuilder();

        subFundNavs.forEach(nav -> {
            fundNav.addNetAssetValue(nav.getNavF());
            fundNav.addSubscription(nav.getSubscriptionValF());
            fundNav.addRedemption(nav.getRedemptionValF());
        });

        return fundNav.build();
    }

    private List<SubFundV2NAVPreviewDTO> getMissingNavs(List<SubFundNetAssetValue> subFundNavs, Predicate<SubFundNetAssetValue> missingNavFct) {
        return subFundNavs.stream()
        		.filter(missingNavFct::test)
        		.map(mapper::toNavPreviewDTO)
        		.toList();
    }

    static class FundNetAssetValueBuilder {

        private final FundNetAssetValueDTO nav = new FundNetAssetValueDTO()
                .netAssetValue(BigDecimal.ZERO)
                .subscriptions(BigDecimal.ZERO)
                .redemptions(BigDecimal.ZERO);

        void addNetAssetValue(BigDecimal netAssetValue) {
            nav.setNetAssetValue(nav.getNetAssetValue().add(netAssetValue));
        }

        void addSubscription(BigDecimal subscription) {
            nav.setSubscriptions(nav.getSubscriptions().add(subscription));
        }

        void addRedemption(BigDecimal redemption) {
            nav.setRedemptions(nav.getRedemptions().add(redemption));
        }

        FundNetAssetValueDTO build() {
            nav.subsMinusReds(nav.getSubscriptions().subtract(nav.getRedemptions()));
            nav.navMinusReds(nav.getNetAssetValue().subtract(nav.getRedemptions()));
            return nav;
        }
    }
}