package com.bdl.epbs_fund_api.repositories;

import org.springframework.data.jpa.repository.JpaRepository;

import com.bdl.epbs_fund_api.model.entities.Team;

import java.util.Optional;

public interface TeamRepository extends JpaRepository<Team, Integer> {

    Optional<Team> findByName(String name);

}
