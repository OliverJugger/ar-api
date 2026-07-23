package com.bdl.epbs_fund_api.services.audit;

import com.bdl.epbs_fund_api.model.AbstractTypeDTO;
import com.bdl.epbs_fund_api.model.TeamDTO;
import com.bdl.epbs_fund_api.model.AddressDTO;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@JsonInclude()
@Data
public class FundDTOAudit {

    @JsonProperty("legal_name")
    private String legalName;

    @JsonProperty("internal_short_name")
    private String internalShortName;

    @JsonProperty("legal_form")
    private AbstractTypeDTO legalForm;

    @JsonProperty("fund_legal_form")
    private AbstractTypeDTO fundLegalForm;

    @JsonProperty("applicable_law")
    private AbstractTypeDTO applicableLaw;

    @JsonProperty("applicable_directive_type")
    private AbstractTypeDTO applicableDirectiveType;

    @JsonProperty("cssf_fund_code")
    private String cssfFundCode;

    @JsonProperty("incorporation_date")
    private LocalDateTime incorporationDate;

    @JsonProperty("financial_year_end_date")
    private LocalDateTime financialYearEndDate;

    @JsonProperty("lei_code")
    private String leiCode;

    /* *********************************************************************/
    /* ****** FUND: OPERATIONAL DATA 								 	 ***/
    /* *********************************************************************/

    @JsonProperty("team")
    private TeamDTO team;

    @JsonProperty("is_self_managed")
    private Boolean isSelfManaged;

    @JsonProperty("currency")
    private AbstractTypeDTO currency;

    /* *********************************************************************/
    /* ****** FUND: FUND TERM			 								 ***/
    /* *********************************************************************/

    @JsonProperty("term_type")
    private AbstractTypeDTO termType;

    @JsonProperty("term_detail")
    private String termDetail;

    @JsonProperty("initial_close_date")
    private LocalDateTime initialCloseDate;

    @JsonProperty("first_extension_term_date")
    private LocalDateTime firstExtensionTermDate;

    @JsonProperty("second_extension_term_date")
    private LocalDateTime secondExtensionTermDate;

    /* *********************************************************************/
    /* ****** FUND: REGULATORY & TAX	 								 ***/
    /* *********************************************************************/

    @JsonProperty("tax_identification_number")
    private String taxIdentificationNumber;

    @JsonProperty("rcs_number")
    private String rcsNumber;

    @JsonProperty("vat_number")
    private String vatNumber;

    @JsonProperty("srab_status")
    private AbstractTypeDTO srabStatus;

    @JsonProperty("personal_asset_holding_vehicle")
    private AbstractTypeDTO personalAssetHoldingVehicle;

    @JsonProperty("dedicated_fund")
    private AbstractTypeDTO dedicatedFund;

    @JsonProperty("institutional_sector")
    private AbstractTypeDTO institutionalSector;

    /* *********************************************************************/
    /* ****** FUND: COMMUNICATION		 								 ***/
    /* *********************************************************************/

    @JsonProperty("website")
    private String website;

    @JsonProperty("registered_office")
    private AddressDTO registeredOffice;

    /* *********************************************************************/
    /* ****** FUND: AVALOQ RELATED		 								 ***/
    /* *********************************************************************/

    @JsonProperty("bp_number")
    private String bpNumber;

    @JsonProperty(value = "operational_specificities_comment")
    private String operationalSpecificitiesComment;

    /* *********************************************************************/
    /* ****** FUND: SUPERVISION 		 								 ***/
    /* *********************************************************************/

    @JsonProperty("regulated_entity_type")
    private AbstractTypeDTO regulatedEntityType;

    @JsonProperty("regulated_as")
    private List<AbstractTypeDTO> regulatedAs;

    @JsonProperty("supervisory_authorities")
    private List<AbstractTypeDTO> supervisoryAuthorities;
}
