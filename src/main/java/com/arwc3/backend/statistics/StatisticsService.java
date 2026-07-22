package com.arwc3.backend.statistics;

import com.arwc3.backend.generated.model.StatisticsResponse;
import org.springframework.stereotype.Service;

@Service
public class StatisticsService {

    private final StatisticEntryRepository statisticEntryRepository;
    private final StatisticMapper statisticMapper;

    public StatisticsService(StatisticEntryRepository statisticEntryRepository, StatisticMapper statisticMapper) {
        this.statisticEntryRepository = statisticEntryRepository;
        this.statisticMapper = statisticMapper;
    }

    public StatisticsResponse getStatistics() {
        StatisticsResponse response = new StatisticsResponse();
        response.setStat1(statisticMapper.toChartData(
                statisticEntryRepository.findByStatGroupOrderByIdAsc(StatGroup.STAT1)));
        response.setStat2(statisticMapper.toChartData(
                statisticEntryRepository.findByStatGroupOrderByIdAsc(StatGroup.STAT2)));
        response.setStat3(statisticMapper.toChartData(
                statisticEntryRepository.findByStatGroupOrderByIdAsc(StatGroup.STAT3)));
        response.setStat4(statisticMapper.toChartData(
                statisticEntryRepository.findByStatGroupOrderByIdAsc(StatGroup.STAT4)));
        return response;
    }
}
