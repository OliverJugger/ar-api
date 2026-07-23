package com.arwc3.entitys;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "DOSSIER_SINISTRE", schema = "ARTHUS")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DossierSinistre {

    @Id
    @Column(name = "IDDOSSIER", length = 9, nullable = false)
    private String idDossier;

    @Column(name = "REF_EXT", length = 30)
    private String refExt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "NUMINDIV", referencedColumnName = "NUMINDIV")
    private Individu individu;

    @Column(name = "ANTERIEUR", length = 1)
    private String anterieur;

    @Column(name = "DEBUT")
    private LocalDateTime debut;

    @Column(name = "NUMUTIL")
    private Integer numUtil;

    @Column(name = "FIN")
    private LocalDateTime fin;

    @Column(name = "CLOTURE")
    private LocalDateTime cloture;

    @Column(name = "CREATEUR")
    private Integer createur;

    @Column(name = "CREATION")
    private LocalDateTime creation;

    @Column(name = "MODIFICATEUR")
    private Integer modificateur;

    @Column(name = "MODIFICATION")
    private LocalDateTime modification;
}