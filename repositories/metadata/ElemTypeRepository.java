package com.bdl.epbs_fund_api.repositories.metadata;

import com.bdl.epbs_fund_api.model.types.ElemType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ElemTypeRepository extends JpaRepository<ElemType, Integer> {

    ElemType findByIntlId(@Param("elemTypeIntlId") String elemTypeIntlId);

}
