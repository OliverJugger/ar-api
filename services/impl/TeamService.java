package com.bdl.epbs_fund_api.services.impl;

import java.util.List;

import com.bdl.epbs_fund_api.model.entities.Team;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import org.springframework.stereotype.Service;

import com.bdl.epbs_fund_api.mappings.TeamMapper;
import com.bdl.epbs_fund_api.model.TeamDTO;
import com.bdl.epbs_fund_api.repositories.TeamRepository;
import com.bdl.epbs_fund_api.services.ITeamService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TeamService implements ITeamService {

	private final TeamMapper teamMapper;

	private final TeamRepository teamRepository;

	@Override
	public List<TeamDTO> getAllTeam() {
		return teamMapper.mapFromTeam(teamRepository.findAll());
	}

	public Team findByName(String name) {
		return teamRepository.findByName(name).orElseThrow(() -> new ResourceNotFoundException("could not find entity with name : " + name));
	}
}
