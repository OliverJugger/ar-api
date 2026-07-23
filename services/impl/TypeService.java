package com.bdl.epbs_fund_api.services.impl;

import java.util.List;

import com.bdl.utils.exceptions.ResourceNotFoundException;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.AbstractTypeMapper;
import com.bdl.epbs_fund_api.model.AbstractTypeDTO;
import com.bdl.epbs_fund_api.model.RelatedEntityTypeDTO;
import com.bdl.epbs_fund_api.model.StaticDataLabelDTO;
import com.bdl.epbs_fund_api.repositories.ProjectScopeRepository;
import com.bdl.epbs_fund_api.repositories.type.AccountTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.ApplicableDirectiveTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.ApplicableLawTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.BusinessUnitTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.CommercialStatusReasonForDecliningTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.CommercialStatusTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.ComplianceOpinionTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.ConvAMAcceptanceStatusTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.CountryCallingCodeRepository;
import com.bdl.epbs_fund_api.repositories.type.DistributionStrategyTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.EPBSCorpEntityLegalFormTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.EPBSFundLegalFormTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.ElecAddressTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.EntityTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.ExpectedNumberInvestorTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.FundStructureTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.GenderTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.InChargeTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.InvestmentGeographyTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.InvestorBaseTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.LangRepository;
import com.bdl.epbs_fund_api.repositories.type.LegalFormTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.MajorChangeRepository;
import com.bdl.epbs_fund_api.repositories.type.PBSAcceptanceStatusTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.PostAddressTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.ProjectDateTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.ProjectRelatedIndividualTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.RegulatedAsTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.RegulatedEntityTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.SRABStatusRepository;
import com.bdl.epbs_fund_api.repositories.type.StatusTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.SubscriptionTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.SupervisoryAuthorityTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.TitleRepository;
import com.bdl.epbs_fund_api.repositories.type.TradingVolumeTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.UnderlyingClientResidenceCountryTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.UseSPVTypeRepository;
import com.bdl.epbs_fund_api.repositories.type.WinProbabilityTypeRepository;
import com.bdl.epbs_fund_api.services.impl.type.ClientSegmentationTypeService;
import com.bdl.epbs_fund_api.services.impl.type.DedicatedSubFundTypeService;
import com.bdl.epbs_fund_api.services.impl.type.ESGClassificationTypeService;
import com.bdl.epbs_fund_api.services.impl.type.InstitutionalSectorTypeService;
import com.bdl.epbs_fund_api.services.impl.type.InvestmentStrategyTypeService;
import com.bdl.epbs_fund_api.services.impl.type.MainInvestmentAssetTypeService;
import com.bdl.epbs_fund_api.services.impl.type.NavFrequencyTypeService;
import com.bdl.epbs_fund_api.services.impl.type.PersonalAssetHoldingVehicleTypeService;
import com.bdl.epbs_fund_api.services.impl.type.TermTypeService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TypeService {

	private final AbstractTypeMapper typeMapper;

	private final StaticDataService staticDataService;
	private final CountryService countryService;
	private final CurrencyService currencyService;
	private final RelatedEntityTypeService relatedEntityTypeService;
	private final UCIEntityTypeService uCIEntityTypeService;
	
	private final MainInvestmentAssetTypeService mainInvestmentAssetTypeService;
	private final InvestmentStrategyTypeService investmentStrategyTypeService;
	private final ESGClassificationTypeService eSGClassificationTypeService;
	private final NavFrequencyTypeService navFrequencyTypeService;
	private final TermTypeService termTypeService;
	private final DedicatedSubFundTypeService dedicatedSubFundTypeService;
	private final PersonalAssetHoldingVehicleTypeService personalAssetHoldingVehicleTypeService;
	private final ClientSegmentationTypeService clientSegmentationTypeService;
	private final InstitutionalSectorTypeService institutionalSectorTypeService;
	
	private final PBSAcceptanceStatusTypeRepository pbsAcceptanceStatusTypeRepository;
	private final EntityTypeRepository entityTypeRepository;
	private final SRABStatusRepository sRABStatusRepository;
	private final ApplicableDirectiveTypeRepository applicableDirectiveTypeRepository;
	private final DistributionStrategyTypeRepository distributionStrategyTypeRepository;
	private final LangRepository langRepository;
	private final ProjectRelatedIndividualTypeRepository projectRelatedIndividualTypeRepository;
	private final StatusTypeRepository statusTypeRepository;
	private final ApplicableLawTypeRepository applicableLawTypeRepository;
	private final LegalFormTypeRepository legalFormTypeRepository;
	private final SupervisoryAuthorityTypeRepository supervisoryAuthorityTypeRepository;
	private final GenderTypeRepository genderTypeRepository;
	private final RegulatedAsTypeRepository regulatedAsTypeRepository;
	private final EPBSFundLegalFormTypeRepository ePBSFundLegalFormTypeRepository;
	private final InChargeTypeRepository inChargeTypeRepository;
	private final RegulatedEntityTypeRepository regulatedEntityTypeRepository;
	private final TitleRepository titleRepository;
	private final CountryCallingCodeRepository countryCallingCodeRepository;
	private final ElecAddressTypeRepository elecAddressTypeRepository;
	private final InvestmentGeographyTypeRepository investmentGeographyTypeRepository;
	private final PostAddressTypeRepository postAddressTypeRepository;
	private final EPBSCorpEntityLegalFormTypeRepository ePBSCorpEntityLegalFormTypeRepository;
	private final AccountTypeRepository accountTypeRepository;
	private final BusinessUnitTypeRepository businessUnitTypeRepository;
	private final CommercialStatusTypeRepository commercialStatusTypeRepository;
	private final CommercialStatusReasonForDecliningTypeRepository commercialStatusReasonForDecliningTypeRepository;
	private final ComplianceOpinionTypeRepository complianceOpinionTypeRepository;
	private final ConvAMAcceptanceStatusTypeRepository convAMAcceptanceStatusTypeRepository;
	private final ExpectedNumberInvestorTypeRepository expectedNumberInvestorTypeRepository;
	private final FundStructureTypeRepository fundStructureTypeRepository;
	private final InvestorBaseTypeRepository investorBaseTypeRepository;
	private final MajorChangeRepository majorChangeRepository;
	private final ProjectDateTypeRepository projectDateTypeRepository;
	private final SubscriptionTypeRepository subscriptionTypeRepository;
	private final TradingVolumeTypeRepository tradingVolumeTypeRepository;
	private final UnderlyingClientResidenceCountryTypeRepository underlyingClientResidenceCountryTypeRepository;
	private final UseSPVTypeRepository useSPVTypeRepository;
	private final WinProbabilityTypeRepository winProbabilityTypeRepository;
	private final ProjectScopeRepository projectScopeRepository;

	public StaticDataLabelDTO getByIntlId(String intlId) {
		return staticDataService.getByIntlId(intlId);
	}
	
	public List<StaticDataLabelDTO> getAllStaticDataTypeByIntlId(String intlId) {
		return staticDataService.getAllStaticDataTypeByIntlId(intlId);
	}

	public List<AbstractTypeDTO> getAllProjectScope() {
		return typeMapper.mapToAbstractTypeEntityDTO(projectScopeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllApplicableDirectiveType() {
		return typeMapper.mapToAbstractTypeEntityDTO(applicableDirectiveTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllApplicableLawType() {
		return typeMapper.mapToAbstractTypeEntityDTO(applicableLawTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllClientSegmentationType() {
		return typeMapper.mapToAbstractTypeEntityDTO(clientSegmentationTypeService.getAllClientSegmentationType());
	}
	
	public List<AbstractTypeDTO> getAllEPBSCorpEntityLegalFormType() {
		return typeMapper.mapToAbstractTypeEntityDTO(ePBSCorpEntityLegalFormTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllCountryCallingCodeType() {
		return typeMapper.mapToAbstractTypeEntityDTO(countryCallingCodeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllCountry() {
		return typeMapper.mapFromCountryDTO(countryService.getAllCountries());
	}
	
	public List<AbstractTypeDTO> getAllCurrency() {
		return typeMapper.mapFromCurrencyDTO(currencyService.getAllCurrency());
	}
	
	public List<AbstractTypeDTO> getAllDistributionStrategyType() {
		return typeMapper.mapToAbstractTypeEntityDTO(distributionStrategyTypeRepository.findAll());
	}

	public List<AbstractTypeDTO> getAllESGClassificationType() {
		return typeMapper.mapToAbstractTypeEntityDTO(eSGClassificationTypeService.getAllESGClassificationType());
	}
	
	public List<AbstractTypeDTO> getAllElecAddressType() {
		return typeMapper.mapToAbstractTypeEntityDTO(elecAddressTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllEntityType() {
		return typeMapper.mapToAbstractTypeEntityDTO(entityTypeRepository.findAll());
	}

	public List<AbstractTypeDTO> getAllFundLegalFormType() {
		return typeMapper.mapToAbstractTypeEntityDTO(ePBSFundLegalFormTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllGenderType() {
		return typeMapper.mapToAbstractTypeEntityDTO(genderTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllInChargeType() {
		return typeMapper.mapToAbstractTypeEntityDTO(inChargeTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllInstitutionalSectorType() {
		return typeMapper.mapToAbstractTypeEntityDTO(institutionalSectorTypeService.getAllInstitutionalSectorType());
	}
	
	public List<AbstractTypeDTO> getAllInvestmentGeographyType() {
		return typeMapper.mapToAbstractTypeEntityDTO(investmentGeographyTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllInvestmentStrategyType() {
		return typeMapper.mapToAbstractTypeEntityDTO(investmentStrategyTypeService.getAllInvestmentStrategyType());
	}
	
	public List<AbstractTypeDTO> getAllLangType() {
		return typeMapper.mapToAbstractTypeEntityDTO(langRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllLegalFormType() {
		return typeMapper.mapToAbstractTypeEntityDTO(legalFormTypeRepository.findAll());
	}

	public AbstractTypeDTO getLegalFormTypeByIntlId(String intlId) {
		return typeMapper.mapToAbstractTypeEntityDTO(legalFormTypeRepository.findByIntlId(intlId).orElseThrow(() -> new ResourceNotFoundException("could not find entity with intlId : " + intlId)));
	}
	
	public List<AbstractTypeDTO> getAllMainInvestmentAssetType() {
		return typeMapper.mapToAbstractTypeEntityDTO(mainInvestmentAssetTypeService.getAllMainInvestmentAssetType());
	}
	
	public List<AbstractTypeDTO> getAllNavFrequencyType() {
		return typeMapper.mapToAbstractTypeEntityDTO(navFrequencyTypeService.getAllNavFrequencyType());
	}

	public List<AbstractTypeDTO> getAllPersonalAssetHoldingVehicleType() {
		return typeMapper.mapToAbstractTypeEntityDTO(personalAssetHoldingVehicleTypeService.getAllPersonalAssetHoldingVehicleType());
	}
	
	public List<AbstractTypeDTO> getAllPostAdressType() {
		return typeMapper.mapToAbstractTypeEntityDTO(postAddressTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllProjectRelatedIndividualType() {
		return typeMapper.mapToAbstractTypeEntityDTO(projectRelatedIndividualTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllRegulatedAsType() {
		return typeMapper.mapToAbstractTypeEntityDTO(regulatedAsTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllRegulatedEntityType() {
		return typeMapper.mapToAbstractTypeEntityDTO(regulatedEntityTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllSRABStatusType() {
		return typeMapper.mapToAbstractTypeEntityDTO(sRABStatusRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllStatusType() {
		return typeMapper.mapToAbstractTypeEntityDTO(statusTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllSupervisoryAuthorityType() {
		return typeMapper.mapToAbstractTypeEntityDTO(supervisoryAuthorityTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllTermType() {
		return typeMapper.mapToAbstractTypeEntityDTO(termTypeService.getAllTermType());
	}
	
	public List<AbstractTypeDTO> getAllTitleType() {
		return typeMapper.mapToAbstractTypeEntityDTO(titleRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllUCIEntityType() {
		return typeMapper.mapToAbstractTypeEntityDTO(uCIEntityTypeService.getAllUCIEntityType());
	}
	
	public List<AbstractTypeDTO> getAllDedicatedSubFundType() {
		return typeMapper.mapToAbstractTypeEntityDTO(dedicatedSubFundTypeService.getAllDedicatedSubFundType());
	}
	
	// THESE TYPES CAN GO IN ABSTRACT TYPE CONTROLLER WHEN PROJECT DESCRIPTION IS
	// OUT OF EPBS-API //
	public List<AbstractTypeDTO> getAllAccountType() {
		return typeMapper.mapToAbstractTypeEntityDTO(accountTypeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllBusinessUnitType() {
		return typeMapper.mapToAbstractTypeEntityDTO(businessUnitTypeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllCommercialStatusReasonForDecliningType() {
		return typeMapper.mapToAbstractTypeEntityDTO(commercialStatusReasonForDecliningTypeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllCommercialStatusType() {
		return typeMapper.mapToAbstractTypeEntityDTO(commercialStatusTypeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllComplianceOpinionType() {
		return typeMapper.mapToComplianceOpinionTypeDTO(complianceOpinionTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllConvAMAcceptanceStatusType() {
		return typeMapper.mapToAbstractTypeEntityDTO(convAMAcceptanceStatusTypeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllExpectedNumberInvestorType() {
		return typeMapper.mapToAbstractTypeEntityDTO(expectedNumberInvestorTypeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllFundStructureType() {
		return typeMapper.mapToAbstractTypeEntityDTO(fundStructureTypeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllInvestorBaseType() {
		return typeMapper.mapToAbstractTypeEntityDTO(investorBaseTypeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllMajorChange() {
		return typeMapper.mapToAbstractTypeEntityDTO(majorChangeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllPBSAcceptanceStatusType() {
		return typeMapper.mapToAbstractTypeEntityDTO(pbsAcceptanceStatusTypeRepository.findAll());
	}
	
	public List<AbstractTypeDTO> getAllProjectDateType() {
		return typeMapper.mapToAbstractTypeEntityDTO(projectDateTypeRepository.findAll());		
	}

	public List<AbstractTypeDTO> getAllSubscriptionType() {
		return typeMapper.mapToAbstractTypeEntityDTO(subscriptionTypeRepository.findAll());		
	}

	public List<AbstractTypeDTO> getAllTradingVolumeType() {
		return typeMapper.mapToAbstractTypeEntityDTO(tradingVolumeTypeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllUnderlyingClientResidenceCountryType() {
		return typeMapper.mapToAbstractTypeEntityDTO(underlyingClientResidenceCountryTypeRepository.findAll());		
	}

	public List<AbstractTypeDTO> getAllUseSPVType() {
		return typeMapper.mapToAbstractTypeEntityDTO(useSPVTypeRepository.findAll());		
	}
	
	public List<AbstractTypeDTO> getAllWinProbabilityType() {
		return typeMapper.mapToAbstractTypeEntityDTO(winProbabilityTypeRepository.findAll());		
	}

	public RelatedEntityTypeDTO getRelatedEntityTypeByIntlId(String intlId) {
		return relatedEntityTypeService.getRelatedEntityTypeByIntlId(intlId);
	}
}
