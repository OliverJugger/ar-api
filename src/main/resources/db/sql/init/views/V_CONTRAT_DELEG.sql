CREATE FORCE VIEW ARTHUS.V_CONTRAT_DELEG AS
SELECT
    contrat.numgar,
    contrat.refcie,
    contrat.numcli,
    contrat.dateff,
    contrat.deleg_prest,
    contrat.typgar,
    indvs.nom
    || ' '
    || indvs.prenom nomcli,
    contrat.type_contrat
  FROM
    contrat,
    indvs
  WHERE
    indvs.numindiv = contrat.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CONTRAT_DELEG FOR ARTHUS.V_CONTRAT_DELEG
