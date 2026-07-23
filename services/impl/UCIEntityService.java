package com.bdl.epbs_fund_api.services.impl;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.mappings.RelUCIEntityStatusTypeMapper;
import com.bdl.epbs_fund_api.model.AbstractTypeDTO;
import com.bdl.epbs_fund_api.model.RelUCIEntityStatusTypeDTO;
import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.model.types.RelUCIEntityStatusType;
import com.bdl.epbs_fund_api.model.types.StatusType;
import com.bdl.epbs_fund_api.model.types.UCIEntityType;
import com.bdl.epbs_fund_api.repositories.RelUCIEntityStatusTypeRepository;
import com.bdl.epbs_fund_api.repositories.UCIEntityRepository;
import com.bdl.epbs_fund_api.services.impl.type.StatusTypeService;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class UCIEntityService {

    private final UCIEntityTypeService uCIEntityTypeService;
    private final UCIEntityRepository uCIEntityRepository;
    private final RelUCIEntityStatusTypeRepository relUCIEntityStatusTypeRepository;
    private final StatusTypeService statusTypeService;
    private final RelUCIEntityStatusTypeMapper relUCIEntityStatusTypeMapper;

    @Autowired
    public UCIEntityService(UCIEntityTypeService uCIEntityTypeService, 
    						UCIEntityRepository uCIEntityRepository,
    						RelUCIEntityStatusTypeRepository relUCIEntityStatusTypeRepository,
    						StatusTypeService statusTypeService,
                            RelUCIEntityStatusTypeMapper relUCIEntityStatusTypeMapper) {
        this.uCIEntityTypeService = uCIEntityTypeService;
        this.uCIEntityRepository = uCIEntityRepository;
        this.relUCIEntityStatusTypeRepository = relUCIEntityStatusTypeRepository;
        this.statusTypeService = statusTypeService;
        this.relUCIEntityStatusTypeMapper = relUCIEntityStatusTypeMapper;
    }
    
    public UCIEntity getUciEntity(Integer uciEntityId) {
    	return uCIEntityRepository.findById(uciEntityId).orElseThrow(() -> new ResourceNotFoundException("coudl not find uciEntity with id : " + uciEntityId)); 
    }

    public UCIEntity createUCIEntity(String intlIdUCIEntityType, LocalDateTime startDate, String intlIdStatusType) {
        // Create UCI Entity
        UCIEntity uciEntity = createNewInstance(intlIdUCIEntityType, startDate);
        // Set Status
        List<RelUCIEntityStatusType> relUCIEntityStatusType = new ArrayList<>();

        RelUCIEntityStatusType entityStatusType = RelUCIEntityStatusType.builder()
                .startDate(startDate)
                .uciEntity(uciEntity)
                .statusType(statusTypeService.getStatusTypeByIntlId(intlIdStatusType))
                .build();
        relUCIEntityStatusType.add(entityStatusType);

        uciEntity.setRelUciStatusTypes(relUCIEntityStatusType);

        return this.uCIEntityRepository.save(uciEntity);
    }

    @Deprecated(since="01/03/2025") // can be deleted when updateFundV2 is ready
    @Transactional
    public UCIEntity updateUCIEntityAndRelStatusType(Integer uciEntityId, List<RelUCIEntityStatusTypeDTO> relUCIEntityStatusTypeDTOs) {
    	log.debug(String.format("Update UCIEntity of type '%s'", Constants.INTL_ID_UCIENTITY_SUB_FUND));
		return uCIEntityRepository.findById(uciEntityId).map(uciEntity -> {
			
			List<String> newStatusTypes = relUCIEntityStatusTypeDTOs.stream()
					.map(RelUCIEntityStatusTypeDTO::getStatusType)
					.map(AbstractTypeDTO::getIntlId)
					.toList();
			
			List<String> oldStatusTypes = uciEntity.getRelUciStatusTypes().stream()
					.map(RelUCIEntityStatusType::getStatusType)
					.map(StatusType::getIntlId)
					.toList();
			//delete all relUciStatusTypes not in new RelUCIEntityStatusTypeDTO List by intlId of Status
			uciEntity.getRelUciStatusTypes().removeIf(rel -> !newStatusTypes.contains(rel.getStatusType().getIntlId()));

			// add new and update values that are still here (status type)
			relUCIEntityStatusTypeDTOs.stream()
				.forEach(relAddOrUpdate -> {
					String intlId = relAddOrUpdate.getStatusType().getIntlId();
					StatusType statusType = statusTypeService.getStatusTypeByIntlId(intlId);
					if(statusType != null) {
						if(oldStatusTypes.contains(intlId)) {
							RelUCIEntityStatusType relToUpdate = uciEntity.getRelUciStatusTypes().stream()
									 	.filter(rel -> intlId.equals(rel.getStatusType().getIntlId()))
									 	.findFirst()
									 	.get();
							relUCIEntityStatusTypeMapper.updateToEntity(relAddOrUpdate, relToUpdate);
							relToUpdate.setStatusType(statusType);
						} else {
							RelUCIEntityStatusType relToAdd = relUCIEntityStatusTypeMapper.toEntity(relAddOrUpdate);
							relToAdd.setUciEntity(uciEntity);
							relToAdd.setStatusType(statusType);
							uciEntity.getRelUciStatusTypes().add(relToAdd);
						}
					} else {
						throw new EntityNotFoundException("Could not find StatusType with intlId : " + intlId);
					}
				});
			
			
			return uCIEntityRepository.save(uciEntity);
		}).orElse(null);
    }

    public UCIEntity findById(Integer uciEntityId) {
        return this.uCIEntityRepository.findById(uciEntityId).orElseThrow(() -> new ResourceNotFoundException("UCI entity " + uciEntityId + " not found."));
    }

    public RelUCIEntityStatusTypeDTO getCurrentStatus(Integer uciEntityId) {
        log.info("getCurrentStatus - UCIEntity id :" + uciEntityId);
        List<RelUCIEntityStatusType> relStatus = relUCIEntityStatusTypeRepository.getRelUCIEntityStatusTypeByUciEntityIdOrderByStartDateDescIdDesc(uciEntityId);
        if (!CollectionUtils.isEmpty(relStatus)) {
            RelUCIEntityStatusType lastRelStatus = relStatus.get(0);
            return relUCIEntityStatusTypeMapper.toDTO(lastRelStatus);
        }
        log.warn("getCurrentStatus - No RelUCIStatusType history found for UCIEntity id :" + uciEntityId);
        return new RelUCIEntityStatusTypeDTO();
    }
    
    public RelUCIEntityStatusTypeDTO getCurrentStatus(List<RelUCIEntityStatusTypeDTO> status) {
        log.info("getCurrentStatus - List<RelUCIEntityStatusType> status");
        
        if (!CollectionUtils.isEmpty(status)) {
            return status.stream()
                	.sorted((s1, s2) -> s2.getStartDate().compareTo(s1.getStartDate()))
                	.toList()
                	.get(0);
        }
        log.warn("getCurrentStatus - No RelUCIStatusType history found from status list");
        return null;
    }

	private UCIEntity createNewInstance(String intlId, LocalDateTime startDate) {
        UCIEntity uciEntity = new UCIEntity();
        UCIEntityType uciEntityType = uCIEntityTypeService.getUCIEntityTypeByIntlId(intlId);
        uciEntity.setType(uciEntityType);
        uciEntity.setUciEntityTypeID(uciEntityType.getId());
        uciEntity.setStartDate(startDate);
        return uCIEntityRepository.save(uciEntity);
    }

}
