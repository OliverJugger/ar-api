package com.bdl.epbs_fund_api.repositories.type;

import java.util.List;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.types.MajorChangeType;

@Repository
public interface MajorChangeRepository extends JpaRepository<MajorChangeType, Integer> {

    @Cacheable(cacheNames = "major_change_cache")
    List<MajorChangeType> findAll();

}
