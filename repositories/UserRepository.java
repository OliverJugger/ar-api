package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByUserIdm(String userIdm);
}
