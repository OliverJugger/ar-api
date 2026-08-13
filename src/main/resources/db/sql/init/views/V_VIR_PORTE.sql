CREATE FORCE VIEW ARTHUS.V_VIR_PORTE AS
SELECT
  vp.numporte
, vp.numremise
, vp.id_cpt
, vp.numligne
, vp.num_fragment
, to_number(VP.MONTANT_OPE)/100  MONTANT_OPE
, to_number(VP.MONTANT_INIT)/100 MONTANT_INI
, TO_DATE(TO_CHAR(VP.DATEFICRGLT), 'DDMMYY') DATE_REGLEMENT
, VP.DATRAIT -- date de l'import
, e.numencaismt
, vp.user_valide
, vp.DAT_VALIDE
, vp.VALIDE
, CASE vpe.id_cpt WHEN   vp.id_cpt THEN   'O' ELSE 'N'END  AS EXCLU
, vpe.DATE_EXCLU               
, vpe.MOTIF_EXCLU              
, vpe.USER_EXCLU
, F_NOMUTIL(USER_EXCLU)   USERNAME_EXCLU
, F_LBLE('VIR_EXCLU',vpe.motif_exclu) LIBELLE_MOTIF
, vp.NUMDONORDRE
, vp.CODOPE
, vp.NUMCPTE
, vp.ETAT
, (select max(c.IDAFFEC) from COMPTE_CLIENT c where VP.NUMENCAISMT = c.numencaismt) idaffec
FROM  VIR_PORTE VP
LEFT OUTER JOIN ENCAISMT e ON VP.NUMENCAISMT = e.numencaismt
--LEFT OUTER JOIN COMPTE_CLIENT c ON VP.NUMENCAISMT = c.numencaismt
LEFT OUTER JOIN vir_porte_exclu vpe on (
                                        vpe.numremise = vp.numremise and
                                        vpe.id_cpt    = vp.id_cpt and
                                        vpe.numligne  = vp.numligne and
                                        vpe.num_fragment = vp.num_fragment
                                        )
WHERE /*NOT EXISTS (SELECT numligne FROM VIR_PORTE_EXCLU WHERE numremise = vp.numremise AND numligne = vp.numligne)
AND*/  vp.numcpte IS NOT NULL 
ORDER BY  DATE_EXCLU desc, vp.num_fragment asc
GO
CREATE OR REPLACE PUBLIC SYNONYM V_VIR_PORTE FOR ARTHUS.V_VIR_PORTE
