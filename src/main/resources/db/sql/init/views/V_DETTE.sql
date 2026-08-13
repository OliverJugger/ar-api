CREATE FORCE VIEW ARTHUS.V_DETTE AS
SELECT dette.iddette, dette.codope, dette.numcli,
          dette.date_fact date_fact, dette.montant, dette.devise,
          dette.montant_d, dette.devise_d, dette.idcompta, dette.ref_ext,
          dette.debut debut, dette.fin fin, dette.etat etat,
          indvs.nom || ' ' || indvs.prenom nomcli, indvs.nom nom,
          indvs.prenom prenom
     FROM indvs, dette
    WHERE indvs.numindiv = dette.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DETTE FOR ARTHUS.V_DETTE
