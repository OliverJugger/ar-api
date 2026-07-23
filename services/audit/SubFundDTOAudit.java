package com.bdl.epbs_fund_api.services.audit;

import java.util.ArrayList;
import java.util.List;

import com.bdl.epbs_fund_api.model.AbstractTypeDTO;
import com.bdl.epbs_fund_api.model.CurrencyDTO;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@JsonInclude()
@Data
public class SubFundDTOAudit {

    @JsonProperty(value = "legal_name")
    private String legalName;

    @JsonProperty(value = "cssfsubfund_code")
    private String cSSFSubfundCode;

    @JsonProperty(value = "lei_code")
    private String leiCode;

    @JsonProperty(value = "fund_accounting_code")
    private String fundAccountingCode;

    /* *********************************************************************/
    /* ****** SUBFUND: INVESTMENTS 		 								 ***/
    /* *********************************************************************/

    @JsonProperty(value = "currency")
    private CurrencyDTO currency;

    @JsonProperty(value = "main_investment_asset_type")
    private AbstractTypeDTO mainInvestmentAssetType;

    @JsonProperty(value = "investment_strategy_type")
    private AbstractTypeDTO investmentStrategyType;

    @JsonProperty(value = "esg_classification_type")
    private AbstractTypeDTO esgClassificationType;

    @JsonProperty(value = "investment_geography_type")
    private List<AbstractTypeDTO> investmentGeographyType = new ArrayList<>();

    @JsonProperty(value = "is_private_asset")
    private Boolean isPrivateAsset;

    @JsonProperty(value = "is_multi_manager")
    private Boolean isMultiManager;

    @JsonProperty(value = "is_feeder")
    private Boolean isFeeder;

    @JsonProperty(value = "is_official_master")
    private Boolean isOfficialMaster;

    /* *********************************************************************/
    /* ****** SUBFUND: OPERATIONAL DATA	 								 ***/
    /* *********************************************************************/

    @JsonProperty(value = "first_nav_date")
    private String firstNavDate;

    @JsonProperty(value = "nav_frequency_type")
    private AbstractTypeDTO navFrequencyType;

    @JsonProperty(value = "nav_computation_method")
    private String navComputationMethod;

    @JsonProperty(value = "active_transaction_cut_off_time")
    private String activeTransactionCutOffTime;

    /* *********************************************************************/
    /* ****** SUBFUND: Regulatory & Distribution						 ***/
    /* *********************************************************************/

    @JsonProperty(value = "is_benchmark_regulation")
    private Boolean isBenchmarkRegulation;

    @JsonProperty(value = "is_money_market_regulation")
    private Boolean isMoneyMarketRegulation;

    @JsonProperty(value = "is_performance_fees")
    private Boolean isPerformanceFees;

    @JsonProperty(value = "distribution_strategy_type")
    private AbstractTypeDTO distributionStrategyType;

    /* *********************************************************************/
    /* ****** SUBFUND: Sub-Fund Term									 ***/
    /* *********************************************************************/

    @JsonProperty(value = "term_type")
    private AbstractTypeDTO termType;

    @JsonProperty(value = "initial_close_date")
    private String initialCloseDate;

    @JsonProperty(value = "first_extension_term_date")
    private String firstExtensionTermDate;

    @JsonProperty(value = "second_extension_term_date")
    private String secondExtensionTermDate;

    @JsonProperty(value = "term_detail")
    private String termDetail;

    /* *********************************************************************/
    /* ****** SUBFUND: 													 ***/
    /* *********************************************************************/

    @JsonProperty(value = "bp_number")
    private String bpNumber;

    @JsonProperty(value = "dedicated_subfund")
    private AbstractTypeDTO dedicatedSubFund;

    @JsonProperty(value = "personal_asset_holding_vehicle")
    private AbstractTypeDTO personalAssetHoldingVehicle;

    @JsonProperty(value = "client_segmentation")
    private AbstractTypeDTO clientSegmentation;

    @JsonProperty(value = "institutional_sector")
    private AbstractTypeDTO institutionalSector;

    @JsonProperty(value = "operational_specificities_comment")
    private String operationalSpecificitiesComment;

    @JsonProperty(value = "investment_strategy_comment")
    private String investmentStrategyComment;
}
