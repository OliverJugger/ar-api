package com.bdl.epbs_fund_api.repositories.access;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.access.Feature;

@Repository
public interface FeatureRepository extends JpaRepository<Feature, Integer> {
    List<Feature> findAllByIntlIdContaining(String intlId);
}