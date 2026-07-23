package com.bdl.epbs_fund_api.services.impl.v2;

import java.util.List;
import java.util.UUID;
import java.util.function.IntFunction;

import org.apache.commons.lang3.StringUtils;
import org.springframework.data.history.Revisions;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.v2.FundMapperV2;
import com.bdl.epbs_fund_api.mappings.v2.RevisionFundMapperV2;
import com.bdl.epbs_fund_api.model.FundAuditedV2DTO;
import com.bdl.epbs_fund_api.model.FundV2DTO;
import com.bdl.epbs_fund_api.model.RevisionFundV2DTO;
import com.bdl.epbs_fund_api.model.entities.Fund;
import com.bdl.epbs_fund_api.model.entities.UCIEntity;
import com.bdl.epbs_fund_api.repositories.FundRepository;
import com.bdl.epbs_fund_api.utils.RevisionUtils;
import com.bdl.utils.exceptions.ResourceNotFoundException;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class FundServiceV2 implements SyncAuditService {

    private final FundMapperV2 fundMapperV2;
    private final FundRepository fundRepository;
    private final RevisionFundMapperV2 revisionFundMapperV2;

    private static final IntFunction<ResourceNotFoundException> NOT_FOUND_EXCEPTION = id -> new ResourceNotFoundException(String.format("Fund with id %s could not be found", id));
    
    public FundV2DTO getFundV2(Integer id) {
        return fundMapperV2.toDTO(
        		fundRepository.findById(id)
        			.orElseThrow(() -> NOT_FOUND_EXCEPTION.apply(id)));
    }

    public FundV2DTO updateFundV2(Integer id, FundV2DTO fundV2DTO) {
        Fund savedFund = fundRepository.findById(Integer.parseInt(fundV2DTO.getId()))
                .map(initialFund -> {
                    Fund fund = fundMapperV2.toEntity(fundV2DTO);
                    fund.setForceAuditVersion(RevisionUtils.incrementAuditVersion(initialFund.getForceAuditVersion()));
                    fund.getUciEntity().setForceAuditVersion(RevisionUtils.incrementAuditVersion(initialFund.getUciEntity().getForceAuditVersion()));
                    return fund;
                })
                .map(fundRepository::save)
                .orElseThrow(() -> NOT_FOUND_EXCEPTION.apply(id));

        return fundMapperV2.toDTO(savedFund);
    }

    public List<RevisionFundV2DTO> getFundRevisionsByIdV2(Integer id) {
        Revisions<Integer, Fund> revisions = fundRepository.findRevisions(id);

          List<RevisionFundV2DTO> revisionFunds = revisions
                .stream()
                .map(revisionFundMapperV2::fromEntityToDTO)
                .toList();

        return RevisionUtils.sortRevisionsAndOrganise(
                revisionFunds,
                (r1, r2) -> Integer.compare(r2.getId(), r1.getId()),
                RevisionFundV2DTO::getAfter,
                RevisionFundV2DTO::getBefore,
                RevisionFundV2DTO::setBefore,
                fundMapperV2);

    }
    
    public RevisionFundV2DTO getFundRevisionByFundIdAndTaskId(Integer id, UUID taskId) {
    	List<RevisionFundV2DTO> revisions = getFundRevisionsByIdV2(id);
    	
    	return revisions.stream()
    		.filter(rev -> StringUtils.equalsIgnoreCase(rev.getAfter().getTaskUid(), taskId.toString()))
    		.findAny()
    		.orElse(null);
    }

    @Override
    public List<Integer> getDesynchronizedIds() {
        return fundRepository.findAll()
                .stream()
                .filter(this::isLastChangeRevision)
                .map(Fund::getId)
                .toList();
    }

    @Override
    public void forceAudit(List<Integer> desynchronizedIds) {
        List<Fund> updatedFunds = fundRepository.findAllById(desynchronizedIds)
                .stream()
                .map(this::updateForceAuditVersions)
                .toList();

        fundRepository.saveAll(updatedFunds);
    }

    private boolean isLastChangeRevision(Fund fund) {
        return fundRepository.findLastChangeRevision(fund.getId())
                .map(lastAudit -> {
                    FundAuditedV2DTO lastValue = fundMapperV2.toAuditDTO(lastAudit.getEntity());
                    FundAuditedV2DTO actualValue = fundMapperV2.toAuditDTO(fund);
                    return !fundMapperV2.toAuditedEquals(lastValue).equals(fundMapperV2.toAuditedEquals(actualValue));
                }).orElse(false);
    }

    private Fund updateForceAuditVersions(Fund fund) {
        fund.setForceAuditVersion(RevisionUtils.incrementAuditVersion(fund.getForceAuditVersion()));

        UCIEntity uciEntity = fund.getUciEntity();
        uciEntity.setForceAuditVersion(RevisionUtils.incrementAuditVersion(uciEntity.getForceAuditVersion()));
        uciEntity.getRelUciStatusTypes()
                .forEach(relation -> relation.setForceAuditVersion(RevisionUtils.incrementAuditVersion(relation.getForceAuditVersion())));

        return fund;
    }
}
