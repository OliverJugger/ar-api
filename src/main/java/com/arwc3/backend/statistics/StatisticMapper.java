package com.arwc3.backend.statistics;

import com.arwc3.backend.generated.model.ChartDatum;
import java.util.List;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface StatisticMapper {

    ChartDatum toChartDatum(StatisticEntry entry);

    List<ChartDatum> toChartData(List<StatisticEntry> entries);
}
