package com.bdl.epbs_fund_api.services.nav;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.navs.KeyFiguresNetAssetValueBuilderService;
import com.bdl.epbs_fund_api.model.CurrencyEnumDTO;
import com.bdl.epbs_fund_api.model.entities.ShareClass;
import com.bdl.epbs_fund_api.model.entities.ShareClassNetAssetValue;
import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.model.navs.KeyFigureInvestran;
import com.bdl.epbs_fund_api.repositories.ShareClassNetAssetValueRepository;
import com.bdl.epbs_fund_api.repositories.SubFundNetAssetValueRepository;
import com.bdl.epbs_fund_api.repositories.SubFundRepository;
import com.bdl.epbs_fund_api.repositories.navs.KeyFiguresInvestranRepository;
import com.bdl.epbs_fund_api.services.impl.ShareClassService;

import lombok.AllArgsConstructor;

/**
 * Shareclass 683 have no currency (in MDLePBS, not in STGePBS)
 *	
 * private static final Map<String, String> FUND_ACCOUNTING_CODE_FROM_OLD_TO_NEW_EFA = Map.of(
 *		"601603", "PE_3104278", // ??
 *		"601602", "PE_2740065", // exist
 *		"NAVAXX105810", "105810"); // 2 existent : pas normal ?? 358 et 605, on exclus 605
 *
 */
@Service
@AllArgsConstructor
public class NetAssetValuesInvestranService {

	private final SubFundRepository subFundRepository;
	private final KeyFiguresInvestranRepository keyFiguresInvestranRepository;
	private final ShareClassNetAssetValueRepository shareClassNetAssetValueRepository;
	private final SubFundNetAssetValueRepository subFundNetAssetValueRepository;

	private final ShareClassService shareClassService;
	private final KeyFiguresNetAssetValueBuilderService keyFiguresNetAssetValueBuilderService;

	private static List<String> navLogs = new ArrayList<>();
	private static LocalDate valuationDate = LocalDate.of(2025, 3, 25);
	
	public void synchronizeSCKeyFigures() {
		List<KeyFigureInvestran> keyFiguresInvestran = keyFiguresInvestranRepository.findAllByValuationDate(valuationDate);
		
		List<String> subFundCodes = keyFiguresInvestran.stream()
				.map(KeyFigureInvestran::getSubFundCode)
				.distinct()
				.toList();
		
		Map<String, SubFund> subFundWithFundAccountingCode = subFundRepository.findAllByFundAccountingCodeIn(subFundCodes) // le Nom + fundaccountingcode ?
				.stream()
				.filter(s -> s.getId() != 605) // ALIMENTED IN NAVAX WITH SAME FundAccountingCode
				.collect(Collectors.toMap(SubFund::getFundAccountingCode, subFund -> subFund));
		
		List<KeyFigureInvestran> keyFiguresInvestranWithExistingCodes =  keyFiguresInvestran
				.stream()
				.filter(k -> {
					boolean isNotFiltered = subFundWithFundAccountingCode.get(k.getSubFundCode()) != null;
					if(!isNotFiltered) {
						navLogs.add("SubFund with FundAccountingCode : '" + k.getSubFundCode() + "' does not exist so keyFigureEFA filtered"); 
					}
					return isNotFiltered;
				})
				.toList();
		
		Map<ShareClass, KeyFigureInvestran> shareClassKeyFigures = linkKeyFiguresToShareClasses(keyFiguresInvestranWithExistingCodes, subFundWithFundAccountingCode);
			
		shareClassKeyFigures
			.entrySet()
			.stream()
			.forEach(entry -> {
				 Optional<ShareClassNetAssetValue> shareClassNetAssetValue = shareClassNetAssetValueRepository.findByShareClassIdAndValueDate(entry.getKey().getId(), valuationDate);
				 shareClassNetAssetValue.ifPresentOrElse(nav -> 
					 navLogs.add("Nav present : compare ShareclassNetAssetValue ["
					     + "ID '" + nav.getId() + "'"
					     + "NavSC '" + nav.getNavSC() + "'"
					     + "Currency '" + nav.getShareClass().getCurrency().getName() + "'"
					     + "] with KeyFigure ["
					     + "NavSC '" + entry.getValue().getNetAssetShareType() + "'"
					     + "Currency '" + entry.getValue().getCcyNavShare() +"'"
					     + "]")
				 , () -> {
					 navLogs.add("No NAV for shareClassId " + entry.getKey().getId() + " and date " + valuationDate);
					 shareClassNetAssetValueRepository.save(keyFiguresNetAssetValueBuilderService.buildShareClassNetAssetValue(valuationDate, entry.getKey(), entry.getValue()));
				 });
			});
	}

	public void synchronizeSFKeyFigures() {
        List<ShareClassNetAssetValue> shareClassNavs = shareClassNetAssetValueRepository.findAllByValueDate(valuationDate);
        Map<SubFund, List<ShareClassNetAssetValue>> subFundsShareClassNavs = new HashMap<>();
        
        shareClassNavs.forEach(scNav -> {
        	SubFund subFundScNav = scNav.getShareClass().getSubFund();
        	if(subFundsShareClassNavs.containsKey(subFundScNav)) {
        		subFundsShareClassNavs.get(subFundScNav).add(scNav);
        	} else {
        		List<ShareClassNetAssetValue> scNavs = new ArrayList<>();
        		scNavs.add(scNav);
        		subFundsShareClassNavs.put(subFundScNav, scNavs);
        	}
        });
        
        subFundsShareClassNavs
        	.entrySet()
        	.stream()
        	.forEach(entry -> subFundNetAssetValueRepository.save(keyFiguresNetAssetValueBuilderService.buildSubFundNetAssetValue(valuationDate, entry.getKey(), entry.getValue())));
	}
	
	private Map<ShareClass, KeyFigureInvestran> linkKeyFiguresToShareClasses (List<KeyFigureInvestran> keyFigures, Map<String, SubFund> subFundsFundAccountingCode) {
		Map<ShareClass, KeyFigureInvestran> shareClassKeyFigures = new HashMap<>();
		keyFigures.forEach(k -> {
				Integer subFundId = subFundsFundAccountingCode.get(k.getSubFundCode()).getId();
				shareClassService.getShareClassBySubFundIdAndShareCodeAndCurrencyName(subFundId, k.getShareCode(), CurrencyEnumDTO.fromValue(k.getCcyNavShare()))
					.ifPresentOrElse(sc -> shareClassKeyFigures.put(sc, k),
							() -> navLogs.add("No ShareClass for keyFigure with "
											+ "subFundCode " + k.getSubFundCode() 
											+ " and shareCode '" + k.getShareCode())
					);
			});
		return shareClassKeyFigures;
	}
	
}
