package com.bdl.epbs_fund_api.services.metadata.impl;

import java.util.Optional;

import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.MasterRecordStorageDTO;
import com.bdl.epbs_fund_api.model.metadata.MasterRecordStorage;
import com.bdl.epbs_fund_api.model.metadata.SourceSystem;
import com.bdl.epbs_fund_api.model.types.ElemType;
import com.bdl.epbs_fund_api.repositories.metadata.MasterRecordStorageRepository;
import com.bdl.epbs_fund_api.services.metadata.mapper.MasterRecordStorageMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MasterRecordStorageService {

    private final ElemTypeService elemTypeService;

    private final SourceSystemService sourceSystemService;

    private final MasterRecordStorageRepository masterRecordStorageRepository;

    private final MasterRecordStorageMapper masterRecordStorageMapper;

    public MasterRecordStorageDTO findByEpbsIdAndElemTypeIntlId(Integer id, String type) {
        return masterRecordStorageMapper.toDTO(masterRecordStorageRepository.findByEpbsIdAndEpbsElemTypeIntlId(id, type));
    }

	public boolean existEpbsData(Integer id, String type) {
		return masterRecordStorageRepository.findByEpbsIdAndEpbsElemTypeIntlId(id, type) != null;
	}

	public boolean existAndIsEpbsData(Integer id, String type) {
		return Optional.ofNullable(masterRecordStorageRepository.findByEpbsIdAndEpbsElemTypeIntlId(id, type))
			.map(MasterRecordStorage::getMasterSourceSystem)
			.map(SourceSystem::getIntlId)
			.map(Constants.INTL_ID_SOURCE_SYS_EPBS::equals)
			.orElse(true);
	}

	public boolean existAndIsAvaloqData(Integer id, String elemTypeIntlId) {
		return Optional.ofNullable(masterRecordStorageRepository.findByEpbsIdAndEpbsElemTypeIntlId(id, elemTypeIntlId))
			.map(MasterRecordStorage::getMasterSourceSystem)
			.map(SourceSystem::getIntlId)
			.map(Constants.INTL_ID_SOURCE_SYS_AVQ::equals)
			.orElse(false);
	}
	
	public void create(Integer epbsId, String elemTypeIntlId) {
		
		ElemType elemType = this.elemTypeService.getElemTypeByIntlId(elemTypeIntlId);
		SourceSystem masterSourceSystem = sourceSystemService.getSourceSystemByIntlId(Constants.INTL_ID_SOURCE_SYS_EPBS);
		
		MasterRecordStorage masterRecordStorage = new MasterRecordStorage();
		
		masterRecordStorage.setEpbsId(epbsId);
		masterRecordStorage.setMasterId(epbsId.toString());
		masterRecordStorage.setEpbsElemType(elemType);
		masterRecordStorage.setMasterElemType(elemType);
		masterRecordStorage.setMasterSourceSystem(masterSourceSystem);
		
		this.masterRecordStorageRepository.save(masterRecordStorage);
	}
	
	public MasterRecordStorageDTO update(MasterRecordStorageDTO masterRecordStorage) {
		
		MasterRecordStorage masterRecord = masterRecordStorageRepository.findByEpbsIdAndEpbsElemTypeIntlId(Integer.valueOf(masterRecordStorage.getEpbsId()), masterRecordStorage.getEpbsElemType().getValue());
		
		ElemType masterElemType = elemTypeService.getElemTypeByIntlId(masterRecordStorage.getMasterElemType().getValue());
		SourceSystem masterSourceSystem = sourceSystemService.getSourceSystemByIntlId(masterRecordStorage.getMasterSourceSystem().getValue()); // 99% use cases : AVQ

		masterRecord.setMasterId(masterRecordStorage.getMasterId());
		masterRecord.setMasterSourceSystem(masterSourceSystem);
		masterRecord.setMasterElemType(masterElemType);
		
		masterRecord = masterRecordStorageRepository.save(masterRecord);
		
		return masterRecordStorageMapper.toDTO(masterRecord);
	}

	public void delete(Integer id, String elemTypeIntlId) {
		Optional.ofNullable(masterRecordStorageRepository.findByEpbsIdAndEpbsElemTypeIntlId(id, elemTypeIntlId))
			.ifPresent(masterRecordStorageRepository::delete);
	}
}
