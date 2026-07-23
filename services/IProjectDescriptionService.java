package com.bdl.epbs_fund_api.services;

import com.bdl.epbs_fund_api.model.CommercialStatusDTO;
import com.bdl.epbs_fund_api.model.PbsAcceptanceCommentDTO;
import com.bdl.epbs_fund_api.model.PbsAcceptanceStatusUpdateDTO;
import com.bdl.epbs_fund_api.model.ProjectDescriptionBaseDTO;
import com.bdl.epbs_fund_api.model.ProjectDescriptionDTO;

import java.util.List;

public interface IProjectDescriptionService {

    ProjectDescriptionDTO getProjectDescription(Integer id);

    List<ProjectDescriptionBaseDTO> getAllProjectDescription();

    ProjectDescriptionDTO createProjectDescription(ProjectDescriptionDTO projectDescriptionDTO);

    ProjectDescriptionDTO updateProjectDescription(Integer id, ProjectDescriptionDTO projectDescriptionDTO);

    ProjectDescriptionDTO updateProjectDescriptionComment(Integer id, PbsAcceptanceCommentDTO pbsAcceptanceCommentDTO);

    ProjectDescriptionDTO updateProjectDescriptionStatus(Integer id, PbsAcceptanceStatusUpdateDTO pbsAcceptanceStatusUpdateDTO);
    
    ProjectDescriptionDTO updateProjectCommercialStatus(Integer id, CommercialStatusDTO commercialStatus);

    List<ProjectDescriptionDTO> getAllProjects(List<Integer> ids);
}
