CREATE FORCE VIEW ARTHUS.V_EN03 AS
SELECT encaismt.codope, encaismt.numencaismt, encaismt.numcli,
          encaismt.ROLE, encaismt.numcpte, encaismt.numchq, encaismt.modpmt,
          encaismt.refpmt, encaismt.datpay, encaismt.debit, encaismt.datcomp,
          encaismt.datcompta, encaismt.numutil,
          DECODE (compte_client.codope, 1, 'gd01', 2, 'gdp1') codapli,
          compte_client.numfact, compte_client.montant, compte_client.monnaie,
          TO_CHAR (compte_client.datope, 'dd/mm/yy') datope, monnaie.symbole,
          vs_compte.numsoc, vs_compte.libcompte, vs_compte.codbque,
          vs_compte.guichet, vs_compte.compte, vs_compte.clerib,
          vs_compte.rais_soc, vs_compte.domicil, vs_compte.emetteur,
          vs_compte.cmpt_gene
        , vs_compte.bban
        , vs_compte.clef_iban
        , vs_compte.bic
        , vs_compte.codpays
     FROM encaismt, compte_client, monnaie, vs_compte
    WHERE monnaie.codmon = compte_client.monnaie
      AND encaismt.numencaismt = compte_client.numencaismt
      AND encaismt.numcli = compte_client.numcli
      AND encaismt.codope = compte_client.codope
      AND compte_client.montant > 0
      AND encaismt.numcpte = vs_compte.numcpte
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EN03 FOR ARTHUS.V_EN03
