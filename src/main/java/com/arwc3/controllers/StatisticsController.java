package com.arwc3.controllers;

import com.arwc3.generated.api.StatisticsApi;
import com.arwc3.generated.model.StatisticsResponseDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class StatisticsController implements StatisticsApi {

    @Override
    public ResponseEntity<StatisticsResponseDTO> getStatistics() {
        return null;
    }
}
