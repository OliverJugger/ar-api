package com.bdl.epbs_fund_api.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.entities.StaticDataLabel;

@Repository
public interface IStaticDataRepository  extends JpaRepository<StaticDataLabel, Integer> {
	List<StaticDataLabel> findByDataTypeIntlId(String intlId);
	
	StaticDataLabel findByIntlId(String intlId);
}
