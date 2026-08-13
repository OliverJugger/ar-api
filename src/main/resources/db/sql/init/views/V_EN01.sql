CREATE FORCE VIEW ARTHUS.V_EN01 AS
SELECT encaismt.codope, encaismt.numencaismt, encaismt.numcli,
          encaismt.numcpte, encaismt.modpmt, encaismt.montant,
          encaismt.monnaie, encaismt.montant_d, encaismt.monnaie_d,
          encaismt.refpmt, encaismt.datpay, remise_banque.ets_payeur,
          remise_banque.lieu_pmt, remise_banque.nom_tireur,
          remise_banque.numremise, remise_banque.TYPE,
          libelle.libelle type_remise, compte.numsoc, compte.libcompte,
          compte.codbque, compte.guichet, compte.compte, compte.clerib,
          compte.rais_soc, compte.domicil, compte.emetteur
        , compte.bban
        , compte.clef_iban
        , compte.bic
        , compte.codpays
     FROM compte, libelle, encaismt, remise_banque
    WHERE compte.numcpte = encaismt.numcpte
      AND libelle.code = remise_banque.TYPE
      AND libelle.mnemo = 'REM'
      AND encaismt.numencaismt = remise_banque.numencaismt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EN01 FOR ARTHUS.V_EN01
