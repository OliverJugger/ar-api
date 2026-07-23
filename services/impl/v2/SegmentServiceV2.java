package com.bdl.epbs_fund_api.services.impl.v2;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.model.EpbsMinimalObjectDTO;
import com.bdl.epbs_fund_api.repositories.SegmentRepository;
import com.bdl.epbs_fund_api.utils.EpbsMinimalObjectUtils;

@Service
public class SegmentServiceV2 {

	@Autowired
	private SegmentRepository segmentRepository;
	
	public List<EpbsMinimalObjectDTO> getSubFundSegments(Integer subFundId, String nameContains) {
		return segmentRepository.findAllNameIdBySubFundIdAndNameContaining(subFundId, nameContains)
				.stream()
				.map(seg -> EpbsMinimalObjectUtils.buildMinimalSegment(seg.getId(), seg.getName()))
				.toList();
	}

}
