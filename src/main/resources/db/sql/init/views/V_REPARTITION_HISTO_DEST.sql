CREATE FORCE VIEW ARTHUS.V_REPARTITION_HISTO_DEST AS
select rb.IDREPARTITION, rb.NUMBENE, rb.DEBUT, rb.VALIDE, rb.ETAT,
   rb.TYPE_DEST , rb.TRAITE, rb.NUMBENE_DEST , rb.POURCENT, nvl(rb.ECHESUIV,rb.DEBUT) ECHEANCE,
   rb.FIN , rb.FRACT, rb.NUMDEST_PJ, rb.EXCLU_DDE_PJ, rb.IRREVOCABLE, rb.MODE_RGLT
   FROM repartition_bene rb WHERE NOT EXISTS( SELECT 1 FROM histo_dest hd WHERE hd.idrepartition = rb.idrepartition and hd.numbene = rb.numbene)
   UNION
   select rb.IDREPARTITION, rb.NUMBENE, hd.DEBUT, rb.VALIDE, rb.ETAT,
   hd.TYPE_DEST, rb.TRAITE, hd.NUMBENE_DEST, rb.POURCENT, nvl(rb.ECHESUIV,rb.DEBUT),
   CASE WHEN NVL(hd.FIN, rb.FIN) > rb.FIN THEN rb.FIN ELSE NVL(hd.FIN, rb.FIN) END FIN,
   rb.FRACT, rb.NUMDEST_PJ, rb.EXCLU_DDE_PJ, rb.IRREVOCABLE, rb.MODE_RGLT
   FROM histo_dest hd, repartition_bene rb WHERE hd.idrepartition = rb.idrepartition and hd.numbene = rb.numbene
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REPARTITION_HISTO_DEST FOR ARTHUS.V_REPARTITION_HISTO_DEST
