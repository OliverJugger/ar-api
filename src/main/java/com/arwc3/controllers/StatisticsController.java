package com.arwc3.controllers;

import com.arwc3.generated.api.StatisticsApi;
import com.arwc3.generated.model.ChartDatumDTO;
import com.arwc3.generated.model.StatisticsResponseDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;
import java.util.List;

@RestController
@RequiredArgsConstructor
public class StatisticsController implements StatisticsApi {

    @Override
    public ResponseEntity<StatisticsResponseDTO> getStatistics() {
        return ResponseEntity.ok(new StatisticsResponseDTO(
            List.of(
                new ChartDatumDTO("Nord", 32d),
                new ChartDatumDTO("Sud", 21d),
                new ChartDatumDTO("Est", 18d),
                new ChartDatumDTO("Ouest", 29d)),
                
            List.of(
                new ChartDatumDTO("Produit A", 32d),
                new ChartDatumDTO("Produit B", 21d),
                new ChartDatumDTO("Produit C", 18d),
                new ChartDatumDTO("Produit D", 29d)),
                
            List.of(
                new ChartDatumDTO("Web", 32d),
                new ChartDatumDTO("Mobile", 21d),
                new ChartDatumDTO("Boutique", 18d)),
                
            List.of(
                new ChartDatumDTO("Livrées", 32d),
                new ChartDatumDTO("En cours", 21d),
                new ChartDatumDTO("Annulées", 18d),
                new ChartDatumDTO("Retournées", 29d))
        ));
    }
}
