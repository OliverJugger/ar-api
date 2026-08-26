package com.arthus.entitys;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;

@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class HistoriqueConnexionUtilisateurId implements Serializable {

    @Column(name = "NOM", length = 30)
    private String nom;
	
    @Column(name = "DATE_DEB")
    private LocalDateTime dateConnexion;

}