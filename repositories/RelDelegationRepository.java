package com.bdl.epbs_fund_api.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.bdl.epbs_fund_api.model.relations.RelDelegation;

public interface RelDelegationRepository extends JpaRepository<RelDelegation, Integer> {
	
	List<RelDelegation> getRelDelegationByRelRelatedEntityId(Integer relatedEntityId);
	
}
