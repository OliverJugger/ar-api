package com.bdl.epbs_fund_api.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.bdl.epbs_fund_api.model.types.RelUCIEntityStatusType;

public interface RelUCIEntityStatusTypeRepository extends JpaRepository<RelUCIEntityStatusType, Integer> {
	
	List<RelUCIEntityStatusType> getRelUCIEntityStatusTypeByUciEntityIdOrderByStartDateDescIdDesc(Integer uciEntityId);
	
}
