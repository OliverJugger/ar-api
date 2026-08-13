CREATE FORCE VIEW ARTHUS.V_REMISE_COMPTA_DETAIL AS
SELECT                                                         /* + RULE */
          remise_compta.idcompta, remise_compta.numsoc,
          pers_societe.abrege nomsoc, remise_compta.codope,
          compta_ope.libelle libope, remise_compta.journal,
          remise_compta.datcompta, d2e (remise_compta.datcompta) edatcompta,
          d2e (remise_compta.debut) edebut, d2e (remise_compta.fin) efin,
          remise_compta.debit debit, remise_compta.credit credit,
          remise_compta.nombre nombre, remise_compta.nombre_central nombre_central
     FROM compta_ope, pers_societe, remise_compta
    WHERE pers_societe.numsoc = remise_compta.numsoc
      AND compta_ope.code = remise_compta.codope
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_COMPTA_DETAIL FOR ARTHUS.V_REMISE_COMPTA_DETAIL
