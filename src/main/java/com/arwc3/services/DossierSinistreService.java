package com.arwc3.services;

import java.math.BigDecimal;
import java.util.List;
import com.arwc3.repositories.DossierSinistreRepository;
import com.arwc3.generated.model.PageDossierSinistreDTO;
import com.arwc3.generated.model.DossierSinistreDTO;
import com.arwc3.mappers.DossierSinistreMapper;
import com.arwc3.entitys.DossierSinistre;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DossierSinistreService {

    private final DossierSinistreRepository dossierSinistreRepository;
    private final DossierSinistreMapper dossierSinistreMapper;

    public PageDossierSinistreDTO getDossiersSinistre(Integer page, Integer size) {
        List<DossierSinistre> dossierSinistres = dossierSinistreRepository.findAllByNumIndiv(94147L);
        BigDecimal count = new BigDecimal(100);
        BigDecimal totalCount = new BigDecimal(100);
        List<DossierSinistreDTO> dossierSinistreDTOs = dossierSinistreMapper.toDossierSinistreDTO(dossierSinistres);
        PageDossierSinistreDTO pageDossierSinistre = new PageDossierSinistreDTO(new BigDecimal(0), new BigDecimal(20), count, totalCount);
        pageDossierSinistre.data(dossierSinistreDTOs);
        return pageDossierSinistre;
    }

}
