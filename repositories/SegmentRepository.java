package com.bdl.epbs_fund_api.repositories;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.bdl.epbs_fund_api.model.entities.Segment;

@Repository
public interface SegmentRepository extends JpaRepository<Segment, Integer> {
	
	@Query("SELECT seg "
			+ "FROM Segment seg "
			+ "WHERE seg.subFundId = :subFundId "
			+ "AND (seg.uciEntity.closeDate is null "
			+ "OR seg.uciEntity.closeDate >= :closeDate)")
	List<Segment> findAllBySubFundIdAndCloseDateAfterOrEquals(@Param("closeDate") LocalDateTime closeDate, @Param("subFundId") Integer subFundId);
	
	Optional<Segment> findLegalNameById(Integer id);
	
	 // FOR EPBS LIGHT OBJECTS (old RELATED OBJECTS) //
	interface SegmentNameId {
		String getId();
		String getName();
	}
	List<SegmentNameId> findAllNameIdByIdIn(List<Integer> ids);
	List<SegmentNameId> findAllNameIdByNameContaining(String name);
	List<SegmentNameId> findAllNameIdBySubFundIdAndNameContaining(Integer subFundId, String name);
}
