CREATE FORCE VIEW ARTHUS.V_AVTTRT AS
SELECT distinct tr.numtr       numtr,
         tr.refexttr    refexttr
         --fr.domaine
  FROM   traite tr,
	 avenant av,
         --frml_reass fr,
         frml_tfc_reass tfc
  WHERE  av.numtr = tr.numtr
  --AND	 tr.numtr = fr.numtr (+)
  AND	 tr.numtr = tfc.numtr (+)
  AND    av.valideav = 'O'
  --AND	 (fr.domaine in (7,8,9)
  --        or fr.domaine is null)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AVTTRT FOR ARTHUS.V_AVTTRT
