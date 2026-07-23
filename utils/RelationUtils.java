package com.bdl.epbs_fund_api.utils;

import java.util.Optional;

import com.bdl.epbs_fund_api.model.FundDTO;
import com.bdl.epbs_fund_api.model.LegalPersonDTO;
import com.bdl.epbs_fund_api.model.NaturalPersonDTO;
import com.bdl.epbs_fund_api.model.RelRelatedEntityDTO;
import com.bdl.epbs_fund_api.model.RelRelatedIndividualDTO;
import com.bdl.epbs_fund_api.model.RelUCILegalPersonDTO;
import com.bdl.epbs_fund_api.model.SubFundDTO;
import com.bdl.utils.exceptions.ResourceNotFoundException;

public class RelationUtils {

    private RelationUtils() {}
    
    public static String getRelatedIndividualName(RelRelatedIndividualDTO relatedIndividual) {
    	return new StringBuilder()
	        .append(getNaturalPersonFirstNameLastName(relatedIndividual.getNaturalPerson()))
	        .append(" ")
	        .append(relatedIndividual.getRelatedIndividualType().getName())
	        .append(" of ")
	        .append(getRelatedIndividualEntityName(relatedIndividual))
	        .toString();
    }
    
    public static String getRelatedEntityName(RelRelatedEntityDTO relRelatedEntityUci) {
    	final RelUCILegalPersonDTO relUCILegalPersonDTO = relRelatedEntityUci.getRelUciLegalPerson();
    	return new StringBuilder()
	        .append(relUCILegalPersonDTO.getUciEntity().getLegalNameOrName())
	        .append(" ")
	        .append(relRelatedEntityUci.getRelatedEntityType().getName())
	        .append(" of ")
	        .append(relUCILegalPersonDTO.getLegalPerson().getLegalName())
	        .toString();
    }
    
    private static String getNaturalPersonFirstNameLastName(NaturalPersonDTO naturalPerson) {
        return naturalPerson.getFirstName() + " " + naturalPerson.getLastName();
    }
    
    private static String getRelatedIndividualEntityName(RelRelatedIndividualDTO relatedIndividual) {
        return Optional.ofNullable(relatedIndividual.getLegalPerson())
                .map(LegalPersonDTO::getLegalName)
                .orElseGet(() -> Optional.ofNullable(relatedIndividual.getFund())
                        .map(FundDTO::getLegalName)
                        .orElseGet(() -> Optional.ofNullable(relatedIndividual.getSubFund())
                                .map(SubFundDTO::getLegalName)
                                .orElseThrow(() -> new ResourceNotFoundException("Could not find entity linked to natural person in related individual"))));
    }

}
