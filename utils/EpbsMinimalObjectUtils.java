package com.bdl.epbs_fund_api.utils;

import com.bdl.epbs_fund_api.model.ElemTypeEnumDTO;
import com.bdl.epbs_fund_api.model.EpbsMinimalObjectDTO;

public class EpbsMinimalObjectUtils {

	private EpbsMinimalObjectUtils() {}
	
	public static EpbsMinimalObjectDTO buildMinimalFund(String id, String legalName) {
		return new EpbsMinimalObjectDTO()
				.id(id)
				.objectName(legalName)
				.type(ElemTypeEnumDTO.FUND.getValue());
	}
	
	public static EpbsMinimalObjectDTO buildMinimalSubFund(String id, String legalName) {
		return new EpbsMinimalObjectDTO()
				.id(id)
				.objectName(legalName)
				.type(ElemTypeEnumDTO.SUBFUND.getValue());
	}
	
	public static EpbsMinimalObjectDTO buildMinimalSegment(String id, String name) {
		return new EpbsMinimalObjectDTO()
				.id(id)
				.objectName(name)
				.type(ElemTypeEnumDTO.SEGMENT.getValue());
	}
	
	public static EpbsMinimalObjectDTO buildMinimalLegalPerson(String id, String legalName) {
		return new EpbsMinimalObjectDTO()
				.id(id)
				.objectName(legalName)
				.type(ElemTypeEnumDTO.LEGAL_PERSON.getValue());
	}
	
	public static EpbsMinimalObjectDTO buildMinimalNaturalPerson(String id, String firstName, String lastName) {
		return new EpbsMinimalObjectDTO()
				.id(id)
				.objectName(firstName + " " + lastName)
				.type(ElemTypeEnumDTO.NATURAL_PERSON.getValue());
	}
	
	public static EpbsMinimalObjectDTO buildMinimalProject(String id, String legalName) {
		return new EpbsMinimalObjectDTO()
				.id(id)
				.objectName(legalName)
				.type(ElemTypeEnumDTO.PROJECT.getValue());
	}
	
}
