package com.arthus.entitys;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "HISTO_CNX_USERS", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class HistoriqueConnexionUtilisateur {

    @EmbeddedId
    private HistoriqueConnexionUtilisateurId id;

}