CREATE FORCE VIEW ARTHUS.VS_COMPTE AS
SELECT TYPE, numcpte, numsoc, libcompte, codbque, guichet, compte, clerib,
          rais_soc, type_ident, identifiant, domicil, emetteur, cmpt_gene,
          monnaie
        , compte.bban
        , compte.clef_iban
        , compte.bic
        , compte.codpays
        , ics
     FROM compte
    WHERE numsoc IN (SELECT numsoc
                       FROM util_soc
                      WHERE numutil = f_numutil)
GO
CREATE OR REPLACE PUBLIC SYNONYM VS_COMPTE FOR ARTHUS.VS_COMPTE
