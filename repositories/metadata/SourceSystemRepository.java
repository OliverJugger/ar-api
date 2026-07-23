package com.bdl.epbs_fund_api.repositories.metadata;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.metadata.SourceSystem;

@Repository
public interface SourceSystemRepository extends JpaRepository<SourceSystem, Integer> {

	SourceSystem findByIntlId(String intlId);
}
