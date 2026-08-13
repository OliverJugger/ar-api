CREATE FORCE VIEW ARTHUS.V_CONTRAT_SOUS AS
SELECT contrat.numgar, contrat.refcie, contrat.numcli, contrat.dateff,
          contrat.deleg_prest, contrat.typgar, indvs.nom || ' ' || indvs.prenom nomcli
     FROM contrat, indvs
    WHERE indvs.numindiv = contrat.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CONTRAT_SOUS FOR ARTHUS.V_CONTRAT_SOUS
