package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.authentication.UserContext;
import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.enums.RoutineExecutionOriginEnum;
import com.bdl.epbs_fund_api.mappings.FundMapper;
import com.bdl.epbs_fund_api.mappings.RevisionMapper;
import com.bdl.epbs_fund_api.mappings.audit.FundAuditMapper;
import com.bdl.epbs_fund_api.model.*;
import com.bdl.epbs_fund_api.model.entities.Fund;
import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.repositories.FundRepository;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.services.access.HasAccess;
import com.bdl.epbs_fund_api.services.audit.*;
import com.bdl.epbs_fund_api.specification.FundSpecification;
import com.bdl.epbs_fund_api.specification.criteria.FundSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.fund.FundRule;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.actuate.endpoint.InvalidEndpointRequestException;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.history.Revision;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.*;

import static com.bdl.epbs_fund_api.constants.Constants.*;

@Service
public class FundService extends EntityLinkedToTaskAuditService<FundRepository, Fund, FundDTOAudit> {

	private final FundMapper fundMapper;

	private final FundAuditMapper fundAuditMapper;

    private final RevisionMapper<FundDTOAudit> revisionMapper;

	private final UCIEntityService uciEntityService;

	private final SubFundService subFundService;
	
	private final List<FundRule> fundRules;

	private final TechnicalAccessService technicalAccessService;

	@Autowired
	public FundService(FundRepository fundRepository, 
			           FundMapper fundMapper,
					   FundAuditMapper fundAuditMapper,
					   RevisionMapper<FundDTOAudit> revisionMapper, 
					   UCIEntityService uciEntityService,
					   @Lazy SubFundService subFundService,
					   List<FundRule> fundRules, TechnicalAccessService technicalAccessService) {
		super(fundRepository);
		this.fundMapper = fundMapper;
		this.fundAuditMapper = fundAuditMapper;
		this.revisionMapper = revisionMapper;
		this.uciEntityService = uciEntityService;
		this.subFundService = subFundService;
		this.fundRules = fundRules;
		this.technicalAccessService = technicalAccessService;
	}


    public Fund getFundEntity(Integer id) {
        return repository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Fund " + id + " not found."));
    }

    @Transactional
    public FundDTO getFund(Integer id) {
        return fundMapper.toDTO(getFundEntity(id));
    }

	@Transactional
	public List<FundDTO> getFunds(String nameContains, List<Integer> ids) {
		if (Objects.isNull(nameContains) && CollectionUtils.isEmpty(ids)) {
			return Collections.emptyList();
		}
		List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();
		String fundName = Optional.ofNullable(nameContains)
				.map(param -> URLDecoder.decode(param, StandardCharsets.UTF_8))
				.map(String::trim)
				.orElse(null);
		FundSearchCriteria fundSearchCriteria = FundSearchCriteria.builder()
				.name(fundName)
				.dataProfileIntlIds(dataProfilesUserIntlId)
				.fundIds(ids)
				.build();
		return fundMapper.toDTO(repository.findAll(new FundSpecification(fundSearchCriteria, fundRules)));
	}

    @HasAccess(EPBS_ROLE_FULL_ACCESS)
    public List<FundDTO> getAllFunds() {
    	return fundMapper.toDTO(repository.findAll(PageRequest.of(0, 100)).getContent());
    }

	public List<RevisionDTO> getFundRevisionsById(Integer id) {
        List<RevisionDTO<FundDTOAudit>> revisionsByUUid = this.getRevisionsByUUid(id);
        return this.revisionMapper.map(revisionsByUUid);
	}

    public List<RevisionDiffItemDTO> getFundRevisionsDiff(Integer id, List<Integer> revisionIds) {
        return this.getRevisionsDiff(id, revisionIds);
    }

    public List<RevisionDiffItemDTO> getFundRevisionsDiffByTask(Integer id, UUID taskUuid) {
        return this.getRevisionsDiff(id, taskUuid.toString());
    }

	@HasAccess(EPBS_ROLE_FUND_CREATE)
	@Transactional
	public FundDTO createFund(FundDTO fundDTO, LocalDateTime uciEntityStartDate) {
		// Create UCI Entity
		UCIEntity uciEntity = uciEntityService.createUCIEntity(Constants.INTL_ID_UCIENTITY_FUND, uciEntityStartDate, UCIStatusEnumDTO.PROSPECT.getValue());

		fundDTO.setFundId(String.valueOf(uciEntity.getId()));

		// Create Fund
		Fund fund = fundMapper.toEntity(fundDTO);
		fund.setTecUser(UserContext.getCurrentUser());
		fund = this.repository.save(fund);
		fund.setUciEntity(uciEntity);

		technicalAccessService.updateTechnicalTables(fund.getFundId(), Constants.INTL_ID_ELEM_FUND);

		return fundMapper.toDTO(fund);
	}
	
    @HasAccess(EPBS_ROLE_FUND_UPDATE_STATIC_DATA)
	@Transactional
	public FundDTO updateFund(Integer id, FundDTO fundDTO) {
		Fund fund = fundMapper.toEntity(fundDTO);

		fund.setTecUser(UserContext.getCurrentUser());

		List<RelUCIEntityStatusTypeDTO> relUCIEntityStatusTypeDTOS = Optional.ofNullable(fundDTO.getUciEntity())
				.map(UCIEntityDTO::getRelUciStatusTypes)
				.orElse(Collections.emptyList());
		UCIEntity uciEntity = Optional.ofNullable(uciEntityService.updateUCIEntityAndRelStatusType(id, relUCIEntityStatusTypeDTOS))
				.orElseThrow(() -> new InvalidEndpointRequestException("Wrong ID", "ID " + id + "does not exist for UCIEntity"));
		fund.setUciEntity(uciEntity);


		Fund savedFund = repository.save(fund);

		if (fund.getPersonId() != null) {
			this.repository.updatePerson(fund.getPersonId().toString(), fund.getFundId());
		}

		return fundMapper.toDTO(savedFund);
	}

	@Transactional
	public List<SegmentDTO> getAllSegmentsByFundId(Integer id) {
		List<SegmentDTO> segments = new ArrayList<>();
		List<SubFundDTO> subFundDTOs = subFundService.findByFundId(id);
		subFundDTOs.forEach(subFund -> segments.addAll(subFundService.findAllSegmentActiveBySubFundId(subFund.getId())));
		return segments;
	}

	@Transactional
	public FundDTO updateFundUnlinkTask(Integer id) {
		repository.unlinkTask(id);
		return repository.findById(id)
				.map(fundMapper::toDTO)
				.orElse(null);
	}

	@Transactional
	public FundDTO updateFundLinkTask(Integer id, UUID taskUid) {
		repository.linkTask(id, taskUid.toString());
		return repository.findById(id)
				.map(fundMapper::toDTO)
				.orElse(null);
	}
	
	public Fund getFundByIdInternal(Integer fundId) {
		return repository.findById(fundId).orElseThrow(() -> new ResourceNotFoundException("Could not find fund with id : " + fundId));
	}

	protected RevisionDTO<FundDTOAudit> getRevisionDtoInstance() {
		final RevisionDTO<FundDTOAudit> fundDTORevisionDTO = new RevisionDTO<>();
        fundDTORevisionDTO.setEntity(new FundDTOAudit());
        fundDTORevisionDTO.setMetadata(new RevisionMetadataDTO());
        return fundDTORevisionDTO;
	}

	protected void mapChild(RevisionDTO<FundDTOAudit> revisionDto, Revision<Integer, Fund> revision) {
		revisionDto.setEntity(fundAuditMapper.toFundDTOAudit(revision.getEntity()));
	}
}