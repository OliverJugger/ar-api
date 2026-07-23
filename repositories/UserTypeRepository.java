package com.bdl.epbs_fund_api.repositories;

import com.bdl.epbs_fund_api.model.types.UserType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserTypeRepository extends JpaRepository<UserType, Integer> {

    Optional<UserType> findByIntlId(String intlId);

}
