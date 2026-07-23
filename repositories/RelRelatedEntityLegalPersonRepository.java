package com.bdl.epbs_fund_api.repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.history.RevisionRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.bdl.epbs_fund_api.model.relations.RelRelatedEntityLegalPerson;

@Repository
public interface RelRelatedEntityLegalPersonRepository extends JpaRepository<RelRelatedEntityLegalPerson, Integer>, RevisionRepository<RelRelatedEntityLegalPerson, Integer, Integer> {

    List<RelRelatedEntityLegalPerson> findByLegalPersonSourceId(Integer id);

    Optional<RelRelatedEntityLegalPerson> findById(Integer id);

    // /!\ WE HAVE NO CHOICE TO USE UPDATE BECAUSE OF AUDIT /!\
    @Modifying
    @Query(value = "UPDATE MDLePBS.RelRelatedEntityLegalPerson SET TaskUID = :taskUid WHERE RelRelatedEntityLegalPersonID = :relRelatedEntityId", nativeQuery = true)
    @Transactional
    void linkTask(
            @Param("relRelatedEntityId") Integer relRelatedEntityId,
            @Param("taskUid") String taskUid);
}
