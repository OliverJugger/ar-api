CREATE FORCE VIEW ARTHUS.CONTRAT AS
SELECT contrat_ref.numgar, contrat_ref.numgar_ref, contrat_ref.refcie,
          contrat_ref.refcie_chapeau, contrat_ref.numorg, contrat_ref.numprod,
          contrat_ref.numcli, contrat_ref.numinterm, contrat_ref.numutil,
          contrat_ref.typgar, contrat_ref.college, contrat_ref.mode_gestion,
          contrat_ref.type_contrat, contrat_ref.datsous, contrat_ref.dateff,
          contrat_ref.gest_cotis, contrat_ref.nat_calc,
          contrat_ref.type_terme, contrat_ref.typequit, contrat_ref.type_calc,
          contrat_ref.mode_calcul, contrat_ref.fract, contrat_ref.arrondi,
          contrat_ref.mregl, contrat_ref.eche_anniv, contrat_ref.revision,
          contrat_ref.delai, contrat_ref.numquerable, contrat_ref.delegataire,
          contrat_ref.destinataire, contrat_ref.gest_prest,
          contrat_ref.deleg_prest, contrat_ref.dereche, contrat_ref.echesuiv,
          contrat_ref.cellule, contrat_ref.renouv, contrat_ref.type_eche,
          contrat_ref.portefeuille, contrat_ref.ct_resp
     FROM contrat_ref
   UNION ALL
   SELECT adhe_collective.numgar, adhe_collective.numgar_ref,
          adhe_collective.refcie, contrat_ref.refcie_chapeau,
          contrat_ref.numorg, contrat_ref.numprod, adhe_collective.numcli,
          contrat_ref.numinterm, adhe_collective.numutil, contrat_ref.typgar,
          adhe_collective.college, contrat_ref.mode_gestion,
          contrat_ref.type_contrat, adhe_collective.datsous,
          adhe_collective.dateff, contrat_ref.gest_cotis,
          contrat_ref.nat_calc, contrat_ref.type_terme, contrat_ref.typequit,
          contrat_ref.type_calc, contrat_ref.mode_calcul,
          adhe_collective.fract, contrat_ref.arrondi, adhe_collective.mregl,
          adhe_collective.eche_anniv, contrat_ref.revision, contrat_ref.delai,
          adhe_collective.numquerable, contrat_ref.delegataire,
          adhe_collective.destinataire, contrat_ref.gest_prest,
          contrat_ref.deleg_prest, adhe_collective.dereche,
          adhe_collective.echesuiv, contrat_ref.cellule, contrat_ref.renouv,
          contrat_ref.type_eche, contrat_ref.portefeuille,
          contrat_ref.ct_resp
     FROM contrat_ref, adhe_collective
    WHERE contrat_ref.numgar = adhe_collective.numgar_ref
GO
CREATE OR REPLACE PUBLIC SYNONYM CONTRAT FOR ARTHUS.CONTRAT
