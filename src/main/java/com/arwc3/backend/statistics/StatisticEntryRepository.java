package com.arwc3.backend.statistics;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StatisticEntryRepository extends JpaRepository<StatisticEntry, Long> {

    List<StatisticEntry> findByStatGroupOrderByIdAsc(StatGroup statGroup);
}
