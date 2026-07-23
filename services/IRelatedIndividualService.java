package com.bdl.epbs_fund_api.services;

import java.util.List;

import com.bdl.epbs_fund_api.model.RelatedIndividualTypeDTO;

public interface IRelatedIndividualService {
	
	List<RelatedIndividualTypeDTO> getAllRelatedIndividualType();

	List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeOfFund(Integer fundId);

	List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeOfLegalPerson(Integer legalPersonId);

	List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeOfSubFund(Integer subFundId);

	List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeOfFund();

	List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeOfLegalPerson();

	List<RelatedIndividualTypeDTO> getAllRelatedIndividualTypeOfSubFund();
}
