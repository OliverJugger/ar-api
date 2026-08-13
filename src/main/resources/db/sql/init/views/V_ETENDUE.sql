CREATE FORCE VIEW ARTHUS.V_ETENDUE AS
SELECT 2 etendue, contrat.numgar cle, contrat.refcie ref_ext
     FROM contrat
   UNION
   SELECT 4, adhe_cntrt.idadhesion, adhe_cntrt.ref_ext
     FROM adhe_cntrt
   UNION
   SELECT 14, proposition.idpropo, proposition.refext
     FROM proposition
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ETENDUE FOR ARTHUS.V_ETENDUE
