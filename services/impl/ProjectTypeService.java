package com.bdl.epbs_fund_api.services.impl;

import com.bdl.epbs_fund_api.mappings.ProjectTypeMapper;
import com.bdl.epbs_fund_api.model.ProjectTypeDTO;
import com.bdl.epbs_fund_api.repositories.ProjectTypeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class ProjectTypeService {

    private final ProjectTypeRepository projectTypeRepository;

    private final ProjectTypeMapper projectTypeMapper;

    public List<ProjectTypeDTO> getAllProjectType() {
        return Optional.of(projectTypeRepository.findAll())
                .map(projectTypeMapper::toDto)
                .orElse(Collections.emptyList());
    }
}
