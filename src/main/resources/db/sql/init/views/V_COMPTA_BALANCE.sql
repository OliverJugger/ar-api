CREATE FORCE VIEW ARTHUS.V_COMPTA_BALANCE AS
SELECT                                                         /* + RULE */
            compta.idcompta, compta.codope,
            NVL (compta.compte_aux, compta.compte) compte, compta.type_ope,
            SUM (DECODE (compta.sens, 'C', compta.montant, NULL)) credit,
            SUM (DECODE (compta.sens, 'D', compta.montant, NULL)) debit
       FROM compta
   GROUP BY compta.idcompta,
            compta.codope,
            NVL (compta.compte_aux, compta.compte),
            compta.type_ope
   ORDER BY compta.idcompta,
            compta.codope,
            NVL (compta.compte_aux, compta.compte),
            compta.type_ope
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_BALANCE FOR ARTHUS.V_COMPTA_BALANCE
