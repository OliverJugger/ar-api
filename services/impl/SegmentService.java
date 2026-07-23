package com.bdl.epbs_fund_api.services.impl;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.SegmentMapper;
import com.bdl.epbs_fund_api.model.SegmentDTO;
import com.bdl.epbs_fund_api.model.entities.Segment;
import com.bdl.epbs_fund_api.repositories.SegmentRepository;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@Deprecated(since="09/04/2025") // delete when subfunds v2 are in production
public class SegmentService {

	@Autowired
	SegmentMapper segmentMapper;
	
	@Autowired
	SegmentRepository segmentRepository;
	
	public List<SegmentDTO> findAllActiveBySubFundId(Integer subFundId) {
		log.debug(String.format("SegmentService::findAllActiveBySubFundId - Load all active segments for sub-fund with id = %s", subFundId));
		
		List<Segment> segments = segmentRepository.findAllBySubFundIdAndCloseDateAfterOrEquals(LocalDateTime.now(), subFundId);
		return segmentMapper.toDTO(segments);
	}

}
