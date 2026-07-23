package com.bdl.epbs_fund_api.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.entities.ProjectDescription;

@Repository
public interface IProjectDescriptionsRepository extends JpaRepository<ProjectDescription, Integer>, JpaSpecificationExecutor<ProjectDescription> {

    // FOR EPBS LIGHT OBJECTS (old RELATED OBJECTS) //
 	interface ProjectDescriptionNameId {
 		String getId();
 		String getName();
 	}
 	List<ProjectDescriptionNameId> findAllNameIdByIdIn(List<Integer> ids);
 	List<ProjectDescriptionNameId> findAllNameIdByNameContaining(String name);

    List<ProjectDescriptionNameId> findByProjectInitiator_FundId(Integer fundId);
    ProjectDescriptionNameId findByProjectInitiator_SubFunds_SubFundId(Integer subfundId);
}
