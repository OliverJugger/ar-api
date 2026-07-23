package com.bdl.epbs_fund_api.services.impl;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.BooleanUtils;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.exception.SubFundNetAssetValueException;
import com.bdl.epbs_fund_api.mappings.SubFundNetAssetValueMapper;
import com.bdl.epbs_fund_api.model.CurrencyEnumDTO;
import com.bdl.epbs_fund_api.model.SubFundNetAssetValueErrorDuplicateDTO;
import com.bdl.epbs_fund_api.model.SubFundNetAssetValueErrorEnumDTO;
import com.bdl.epbs_fund_api.model.SubFundNetAssetValueErrorExchangeDTO;
import com.bdl.epbs_fund_api.model.SubFundNetAssetValueErrorRangeConsistencyDTO;
import com.bdl.epbs_fund_api.model.SubFundNetAssetValueUnprocessableErrorDTO;
import com.bdl.epbs_fund_api.model.entities.SubFundNetAssetValue;
import com.bdl.epbs_fund_api.repositories.SubFundNetAssetValueRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SubFundNetAssetValueValidatorService {

    private final SubFundNetAssetValueMapper subFundNetAssetValueMapper;
    private final SubFundNetAssetValueRepository subFundNetAssetValueRepository;
    
    private static final Integer MAX_PERCENTAGE_RANGE_VARIATION = 100;
    private static final Integer MIN_PERCENTAGE_RANGE_VARIATION = -50;
	
	public void validateCreateSubFundNetAssetValue(SubFundNetAssetValue newSubFundNetAssetValue, Boolean xIgnoreWarning) {
		List<SubFundNetAssetValueUnprocessableErrorDTO> subFundNetAssetValueErrors = new ArrayList<>();
		
		validateDuplicate(newSubFundNetAssetValue).ifPresent(subFundNetAssetValueErrors::add);
		if(!BooleanUtils.isTrue(xIgnoreWarning)) {
			validateExchange(newSubFundNetAssetValue).ifPresent(subFundNetAssetValueErrors::add);
			validateRangeConsistency(newSubFundNetAssetValue).ifPresent(subFundNetAssetValueErrors::add);
		}
		
		if(CollectionUtils.isNotEmpty(subFundNetAssetValueErrors)) {
			throw new SubFundNetAssetValueException(subFundNetAssetValueErrors);
		}
		
	}
	
	public void validateUpdateSubFundNetAssetValue(SubFundNetAssetValue newSubFundNetAssetValue, Boolean xIgnoreWarning) {
		List<SubFundNetAssetValueUnprocessableErrorDTO> subFundNetAssetValueErrors = new ArrayList<>();
		
		if(!BooleanUtils.isTrue(xIgnoreWarning)) {
			validateExchange(newSubFundNetAssetValue).ifPresent(subFundNetAssetValueErrors::add);
			validateRangeConsistency(newSubFundNetAssetValue).ifPresent(subFundNetAssetValueErrors::add);
		}
		
		if(CollectionUtils.isNotEmpty(subFundNetAssetValueErrors)) {
			throw new SubFundNetAssetValueException(subFundNetAssetValueErrors);
		}
	}
	
	private Optional<SubFundNetAssetValueUnprocessableErrorDTO> validateExchange(SubFundNetAssetValue newSubFundNetAssetValue) {
		if(Objects.isNull(newSubFundNetAssetValue.getNavBank())) {
			return Optional.of(new SubFundNetAssetValueUnprocessableErrorDTO()
					.type(SubFundNetAssetValueErrorEnumDTO.EXCHANGE_DATE_MISSING)
					.data(new SubFundNetAssetValueErrorExchangeDTO()
						.newSubFundNetAssetValue(subFundNetAssetValueMapper.toErrorDTO(newSubFundNetAssetValue))
						.currencyFrom(CurrencyEnumDTO.fromValue(newSubFundNetAssetValue.getSubFund().getCurrency().getName()))
						.currencyTo(CurrencyEnumDTO.EUR)));
		}
		else {
			return Optional.empty();
		}
	}
	
	private Optional<SubFundNetAssetValueUnprocessableErrorDTO> validateDuplicate(SubFundNetAssetValue newSubFundNetAssetValue) {
		return subFundNetAssetValueRepository.findBySubFundIdAndValueDate(newSubFundNetAssetValue.getSubFund().getId(), newSubFundNetAssetValue.getValueDate())
				.map(existingNav -> new SubFundNetAssetValueUnprocessableErrorDTO()
						.type(SubFundNetAssetValueErrorEnumDTO.DUPLICATE_NAV_SUBFUND_VALUE_DATE)
						.data(new SubFundNetAssetValueErrorDuplicateDTO()
								.newSubFundNetAssetValue(subFundNetAssetValueMapper.toErrorDTO(newSubFundNetAssetValue))
								.oldSubFundNetAssetValue(subFundNetAssetValueMapper.toDTO(existingNav))));
	}
	
	private Optional<SubFundNetAssetValueUnprocessableErrorDTO> validateRangeConsistency(SubFundNetAssetValue newSubFundNetAssetValue) {
		return subFundNetAssetValueRepository
					.findFirstBySubFundIdAndValueDateBeforeOrderByValueDateDesc(newSubFundNetAssetValue.getSubFund().getId(), newSubFundNetAssetValue.getValueDate())
					.map(previousNav -> {
						BigDecimal previousNavSF = previousNav.getNavSF();
						BigDecimal nextNavSF = newSubFundNetAssetValue.getNavSF();
						
						Integer percentageRangeVariation = nextNavSF
								.subtract(previousNavSF)
								.divide(previousNavSF, new MathContext(15, RoundingMode.HALF_EVEN))
								.multiply(new BigDecimal(100), new MathContext(15, RoundingMode.HALF_EVEN))
								.intValue();
						
						return (percentageRangeVariation >= MAX_PERCENTAGE_RANGE_VARIATION || percentageRangeVariation <= MIN_PERCENTAGE_RANGE_VARIATION)
									? new SubFundNetAssetValueUnprocessableErrorDTO()
										.type(SubFundNetAssetValueErrorEnumDTO.RANGE_CONSISTENCY_INVALID)
										.data(new SubFundNetAssetValueErrorRangeConsistencyDTO()
												.newSubFundNetAssetValue(subFundNetAssetValueMapper.toErrorDTO(newSubFundNetAssetValue))
												.oldSubFundNetAssetValue(subFundNetAssetValueMapper.toDTO(previousNav))
												.percentageVariation(percentageRangeVariation))
									: null;
					});
	}
	
}
