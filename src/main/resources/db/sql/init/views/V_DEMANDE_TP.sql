CREATE FORCE VIEW ARTHUS.V_DEMANDE_TP AS
SELECT demande_tp.numindiv, demande_tp.idparam_tp, porte_adhesion.numporte,
          porte_adhesion.idadhesion, porte_adhesion.debut, porte_adhesion.fin,
          porte_adhesion.transmis, porte_adhesion.idporte
     FROM demande_tp, porte_adhesion
    WHERE porte_adhesion.idporte = demande_tp.idporte
   UNION
   SELECT demande_tp_ad.numindiv, demande_tp.idparam_tp,
          porte_adhesion.numporte, porte_adhesion.idadhesion,
          porte_adhesion.debut, porte_adhesion.fin, porte_adhesion.transmis,
          porte_adhesion.idporte
     FROM demande_tp_ad, demande_tp, porte_adhesion
    WHERE porte_adhesion.idporte = demande_tp_ad.idporte
      AND demande_tp.idporte = demande_tp_ad.idporte
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DEMANDE_TP FOR ARTHUS.V_DEMANDE_TP
