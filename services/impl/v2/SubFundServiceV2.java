package com.bdl.epbs_fund_api.services.impl.v2;

import java.util.List;
import java.util.UUID;
import java.util.function.IntFunction;

import org.apache.commons.lang3.StringUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.history.Revisions;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.v2.RevisionSubFundMapperV2;
import com.bdl.epbs_fund_api.mappings.v2.SubFundMapperV2;
import com.bdl.epbs_fund_api.model.RevisionSubFundV2DTO;
import com.bdl.epbs_fund_api.model.SubFundAuditedV2DTO;
import com.bdl.epbs_fund_api.model.SubFundV2DTO;
import com.bdl.epbs_fund_api.model.SubFundV2PreviewDTO;
import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.repositories.SubFundRepository;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.specification.SubFundSpecification;
import com.bdl.epbs_fund_api.specification.criteria.SubFundSearchCriteria;
import com.bdl.epbs_fund_api.specification.rule.sub_fund.SubFundRule;
import com.bdl.epbs_fund_api.utils.RevisionUtils;
import com.bdl.epbs_fund_api.utils.UCIEntityUtils;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SubFundServiceV2 implements SyncAuditService {
	
    private final SubFundMapperV2 subFundMapperV2;
    private final RevisionSubFundMapperV2 revisionSubFundMapperV2;
    private final TechnicalAccessService technicalAccessService;
    private final List<SubFundRule> subFundRules;
    private final SubFundRepository subFundRepository;
    
    private static final IntFunction<ResourceNotFoundException> NOT_FOUND_EXCEPTION = id -> new ResourceNotFoundException(String.format("Subfund with id %s could not be found", id));
    
    public SubFundV2DTO getSubFundByIdV2(Integer id) {
        return subFundMapperV2.toDTO(
        		subFundRepository.findById(id)
        			.orElseThrow(() -> NOT_FOUND_EXCEPTION.apply(id)));
    }
    
    public Page<SubFundV2DTO> getAllSubFundsV2(Integer page, Integer size, SubFundSearchCriteria search) {
        List<String> dataProfilesUserIntlId = technicalAccessService.getUserProfilesIntId();
        search.setDataProfileIntlIds(dataProfilesUserIntlId);

        return subFundRepository.findAll(new SubFundSpecification(search, subFundRules), PageRequest.of(page, size))
                .map(subFundMapperV2::toDTO);
    }
    
    // access right is check in Process
    public SubFundV2DTO updateSubFundV2(Integer subFundId, SubFundV2DTO subFundDTO) {

        SubFund subFundSaved = subFundRepository.findById(Integer.parseInt(subFundDTO.getId()))
                .map(initialSubFund -> {
                    SubFund subFund = subFundMapperV2.toEntity(subFundDTO);
                    subFund.setForceAuditVersion(RevisionUtils.incrementAuditVersion(initialSubFund.getForceAuditVersion()));
                    subFund.getUciEntity().setForceAuditVersion(RevisionUtils.incrementAuditVersion(initialSubFund.getUciEntity().getForceAuditVersion()));
                    subFund.setFund(initialSubFund.getFund());
                    return subFund;
                })
                .map(subFundRepository::save)
                .orElseThrow(() -> NOT_FOUND_EXCEPTION.apply(subFundId));

        return subFundMapperV2.toDTO(subFundSaved);
    }
    
    public List<RevisionSubFundV2DTO> getSubFundRevisionsByIdV2(Integer subFundId) {

        Revisions<Integer, SubFund> revisions = subFundRepository.findRevisions(subFundId);

        List<RevisionSubFundV2DTO> revisionSubFunds = revisions
                .stream()
                .map(revisionSubFundMapperV2::fromEntityToDTO)
                .toList();

        return RevisionUtils.sortRevisionsAndOrganise(
                revisionSubFunds,
                (r1, r2) -> Integer.compare(r2.getId(), r1.getId()),
                RevisionSubFundV2DTO::getAfter,
                RevisionSubFundV2DTO::getBefore,
                RevisionSubFundV2DTO::setBefore,
                subFundMapperV2);
    } 
    
    public RevisionSubFundV2DTO getSubFundRevisionBySubFundIdAndTaskId(Integer subFundId, UUID taskId) {
    	List<RevisionSubFundV2DTO> revisions = getSubFundRevisionsByIdV2(subFundId);
    	
    	return revisions.stream()
    		.filter(rev -> StringUtils.equalsIgnoreCase(rev.getAfter().getTaskUid(), taskId.toString()))
    		.findAny()
    		.orElse(null);
    }

    public List<SubFundV2PreviewDTO> findSubFundPreviewByFundId(Integer fundId) {
    	return subFundMapperV2.toDTO(subFundRepository.findAll(new SubFundSpecification(SubFundSearchCriteria.builder().fundId(fundId).build(), subFundRules)))
                .stream()
                .map(subFundDTO -> new SubFundV2PreviewDTO()
                            .id(subFundDTO.getId())
                            .legalName(subFundDTO.getLegalName())
                            .currentStatus(UCIEntityUtils.getCurrentStatus(subFundDTO.getStatuses())))
                .toList();
    }

    @Override
    public List<Integer> getDesynchronizedIds() {
        return subFundRepository.findAll()
                .stream()
                .filter(this::isLastChangeRevision)
                .map(SubFund::getId)
                .toList();
    }

    @Override
    public void forceAudit(List<Integer> desynchronizedIds) {
        List<SubFund> subFundForceAudits = subFundRepository.findAllById(desynchronizedIds)
                .stream()
                .map(this::updateForceAuditVersions)
                .toList();

        subFundRepository.saveAll(subFundForceAudits);
    }

    private boolean isLastChangeRevision(SubFund subFund) {
        return subFundRepository.findLastChangeRevision(subFund.getId())
                .map(lastAudit -> {
                    SubFundAuditedV2DTO lastValue = subFundMapperV2.toAuditDTO(lastAudit.getEntity());
                    SubFundAuditedV2DTO actualValue = subFundMapperV2.toAuditDTO(subFund);
                    return !subFundMapperV2.toAuditedEquals(lastValue).equals(subFundMapperV2.toAuditedEquals(actualValue));
                }).orElse(false);
    }

    private SubFund updateForceAuditVersions(SubFund subFund) {
        UCIEntity initialUci = subFund.getUciEntity();
        subFund.setForceAuditVersion(RevisionUtils.incrementAuditVersion(subFund.getForceAuditVersion()));
        initialUci.setForceAuditVersion(RevisionUtils.incrementAuditVersion(initialUci.getForceAuditVersion()));
        initialUci.getRelUciStatusTypes().forEach(rel -> rel.setForceAuditVersion((RevisionUtils.incrementAuditVersion(rel.getForceAuditVersion()))));
        return subFund;
    }
}
