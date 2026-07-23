package com.bdl.epbs_fund_api.utils;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

import org.apache.commons.lang3.StringUtils;

import com.bdl.epbs_fund_api.model.UCIStatusDTO;
import com.bdl.epbs_fund_api.model.UCIStatusEnumDTO;

public class UCIEntityUtils {
	
	private UCIEntityUtils() {}
	
	public static final List<String> UCI_CLOSE_STATUS = List.of(
    		UCIStatusEnumDTO.LIQUIDATED.getValue(),
    		UCIStatusEnumDTO.ABANDONED.getValue());

    public static final List<UCIStatusEnumDTO> UCI_STATUS_ORDER = List.of(
            UCIStatusEnumDTO.PROSPECT,
    		UCIStatusEnumDTO.PROJECT, 
    		UCIStatusEnumDTO.ACTIVE, 
    		UCIStatusEnumDTO.PUT_INTO_LIQUIDATION,
    		UCIStatusEnumDTO.LIQUIDATED,
    		UCIStatusEnumDTO.ABANDONED
    );
    
    private static final String SUFFIX_STATUS_ABANDONNED = " - ABANDONNED";
    private static final String SUFFIX_STATUS_LIQUIDATED = " - LIQUIDATED";
    private static final String SUFFIX_STATUS_PUT_INTO_LIQUIDATION = " - IN LIQUIDATION";
    
    private static final Map<UCIStatusEnumDTO, String> UCI_LEGAL_NAME_SUFFIX_STATUS = Map.of(
    		UCIStatusEnumDTO.ABANDONED, SUFFIX_STATUS_ABANDONNED,
    		UCIStatusEnumDTO.LIQUIDATED, SUFFIX_STATUS_LIQUIDATED,
    		UCIStatusEnumDTO.PUT_INTO_LIQUIDATION, SUFFIX_STATUS_PUT_INTO_LIQUIDATION);
    
    private static final List<UCIStatusEnumDTO> SUFFIX_STATUSES = List.of(UCIStatusEnumDTO.ABANDONED, UCIStatusEnumDTO.LIQUIDATED, UCIStatusEnumDTO.PUT_INTO_LIQUIDATION);
    
    public static boolean isSuffixCurrentStatusAndHasNotSuffixStatusName(UCIStatusEnumDTO currentStatus, String legalName) {
    	return SUFFIX_STATUSES.contains(currentStatus) && !legalName.endsWith(UCI_LEGAL_NAME_SUFFIX_STATUS.getOrDefault(currentStatus, ""));
    }
    
    public static UCIStatusDTO getCurrentStatus(List<UCIStatusDTO> statuses) {
    	return statuses
        		.stream()
        		.filter(status -> Objects.nonNull(status.getStartDate()))
        		.sorted(Comparator.<UCIStatusDTO>comparingInt(status -> UCI_STATUS_ORDER.indexOf(status.getStatusType())).reversed())
        		.findFirst()
        		.orElse(null);
    }
    
    public static String getLegalNameWithoutSuffix(String currentLegalName) {
    	return currentLegalName
    			.replace(SUFFIX_STATUS_ABANDONNED, "")
    			.replace(SUFFIX_STATUS_LIQUIDATED, "")
    			.replace(SUFFIX_STATUS_PUT_INTO_LIQUIDATION, "");
    }
    
    public static String getLegalNameSuffixFromStatus(List<UCIStatusDTO> statuses, String currentLegalName) {
    	return Optional.ofNullable(getCurrentStatus(statuses))
    			.map(UCIStatusDTO::getStatusType)
    			.filter(currentStatus -> isSuffixCurrentStatusAndHasNotSuffixStatusName(currentStatus, currentLegalName))
    			.map(status -> UCI_LEGAL_NAME_SUFFIX_STATUS.getOrDefault(status, StringUtils.EMPTY))
    			.orElse(StringUtils.EMPTY);
    }
}
