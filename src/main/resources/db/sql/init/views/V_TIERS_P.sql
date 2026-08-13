CREATE FORCE VIEW ARTHUS.V_TIERS_P AS
SELECT ALL 3 typbene, pers_tiers.numtiers, indvs.nom,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     1,
                                     indvs.numindiv
                                    ) ADR0_L1,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     2,
                                     indvs.numindiv
                                    ) ADR0_L2,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     3,
                                     indvs.numindiv
                                    ) ADR0_L3,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     4,
                                     indvs.numindiv
                                    ) ADR0_L4,
              pers_tiers.nomp,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              11
                                                             ),
                                     1,
                                     indvs.numindiv
                                    ) ADR11_L1,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              11
                                                             ),
                                     2,
                                     indvs.numindiv
                                    ) ADR11_L2,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              11
                                                             ),
                                     3,
                                     indvs.numindiv
                                    ) ADR11_L3,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              11
                                                             ),
                                     4,
                                     indvs.numindiv
                                    ) ADR11_L4,
              rib.modpmt, rib.codbque, rib.guichet, rib.compte, rib.clerib,
              rib.intitule, rib.bban, rib.clef_iban, rib.bic, indvs.numindiv,
              'Fournisseur - ' || indvs.nom contexte,
                 pers_tiers.numdpt
              || pers_tiers.numactv
              || pers_tiers.numinser
              || pers_tiers.numcle CODE_TIERS
         FROM indvs, pers_tiers, rib
        WHERE rib.idrib = f_bene_rib (pers_tiers.numindiv, 1, 0, 1)
          AND (    (indvs.numindiv = pers_tiers.numindiv)
               AND (pers_tiers.numindiv = rib.numindiv)
              )
--
   UNION ALL
--
   SELECT ALL 2 typbene, pers_tierspayant.numtp, indvs.nom,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     1,
                                     indvs.numindiv
                                    ) ADR0_L1,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     2,
                                     indvs.numindiv
                                    ) ADR0_L2,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     3,
                                     indvs.numindiv
                                    ) ADR0_L3,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     4,
                                     indvs.numindiv
                                    ) ADR0_L4,
              indvs.nom,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     1,
                                     indvs.numindiv
                                    ) ADR11_L1,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     2,
                                     indvs.numindiv
                                    ) ADR11_L2,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     3,
                                     indvs.numindiv
                                    ) ADR11_L3,
              ARTHUS.pk_personne.f_adresse (ARTHUS.pk_personne.f_idadresse (indvs.numindiv,
                                                              0,
                                                              SYSDATE,
                                                              'O',
                                                              0
                                                             ),
                                     4,
                                     indvs.numindiv
                                    ) ADR11_L4,
              rib.modpmt, rib.codbque, rib.guichet, rib.compte, rib.clerib,
              rib.intitule, rib.bban, rib.clef_iban, rib.bic, indvs.numindiv,
              'Organisme T.P. - ' || indvs.nom, NULL
         FROM pers_tierspayant, indvs, rib
        WHERE rib.idrib = f_bene_rib (pers_tierspayant.numindiv, 1, 0, 1)
          AND (    (indvs.numindiv = pers_tierspayant.numindiv)
               AND (pers_tierspayant.numindiv = rib.numindiv)
              )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TIERS_P FOR ARTHUS.V_TIERS_P
