package com.bdl.epbs_fund_api.services.metadata.mapper;

import java.util.List;

import org.mapstruct.InjectionStrategy;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;

import com.bdl.epbs_fund_api.model.ElemTypeEnumDTO;
import com.bdl.epbs_fund_api.model.MasterRecordStorageDTO;
import com.bdl.epbs_fund_api.model.SourceSystemEnumDTO;
import com.bdl.epbs_fund_api.model.metadata.MasterRecordStorage;
import com.bdl.epbs_fund_api.model.metadata.SourceSystem;
import com.bdl.epbs_fund_api.model.types.ElemType;

@Mapper(
	componentModel = "spring",
	unmappedTargetPolicy = ReportingPolicy.ERROR,
	injectionStrategy = InjectionStrategy.CONSTRUCTOR)
public interface MasterRecordStorageMapper {

	@Mapping(target="epbsElemType", source="epbsElemType", qualifiedByName="mapElemType")
	@Mapping(target="masterElemType", source="masterElemType", qualifiedByName="mapElemType")
	@Mapping(target="masterSourceSystem", source="masterSourceSystem", qualifiedByName="mapSourceSystem")
	public MasterRecordStorageDTO toDTO(MasterRecordStorage source);
	public List<MasterRecordStorageDTO> toDTO(List<MasterRecordStorage> source);
	
	@Named("mapElemType")
	default ElemTypeEnumDTO mapElemType(ElemType source) {
		return ElemTypeEnumDTO.fromValue(source.getIntlId());
	}
	
	@Named("mapSourceSystem")
	default SourceSystemEnumDTO mapSourceSystem(SourceSystem source) {
		return SourceSystemEnumDTO.fromValue(source.getIntlId());
	}

}
