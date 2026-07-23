package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.AccountType;

@Repository
public interface AccountTypeRepository extends JpaRepository<AccountType, Integer> {

    @Cacheable(cacheNames = "account_cache")
	List<AccountType> findAll();

}
