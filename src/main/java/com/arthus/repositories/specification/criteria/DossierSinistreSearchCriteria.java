package com.arthus.repositories.specification.criteria;

import java.time.LocalDate;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DossierSinistreSearchCriteria {
	
    private String numeroDossierContains;
    private String numeroAssureContains;
    private Long numeroContrat;
	private Boolean anterieur;
    private Boolean finNull;
    private String nomIndividuContains;
    private String prenomIndividuContains;
    private LocalDate debutFrom;
    private LocalDate debutTo;
    private LocalDate finFrom;
    private LocalDate finTo;
    
}