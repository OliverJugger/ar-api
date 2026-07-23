package com.bdl.epbs_fund_api.repositories.type;
import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.PostAddressType;

@Repository
public interface PostAddressTypeRepository extends JpaRepository<PostAddressType, Integer> {
	
    @Cacheable(cacheNames = "post_address_type")
    List<PostAddressType> findAll();

}
