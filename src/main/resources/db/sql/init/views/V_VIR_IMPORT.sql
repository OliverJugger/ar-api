CREATE FORCE VIEW ARTHUS.V_VIR_IMPORT AS
SELECT numporte
      ,fichier
      ,numremise
      ,datefic  
      ,count(NUMLIGNE) nb_virement                         --RKO ET ABO M0005818
      ,sum(NVL(montant_total,0)) montant_total
      ,sum(NVL(montant_affecte,0)) +sum(NVL(montant_a_affec,0)) montant_valide -- le boulot terminé
      ,sum(NVL(mt_non_valide,0)) - sum(NVL(mnt_excl,0)) mt_non_valide --sans encaissement de créer deduit des exclus
      ,sum(NVL(mnt_excl,0)) mnt_excl --pas à traiter par le gestionnaire
      ,0 montant_encaismt
      ,sum(NVL(montant_a_affec,0)) montant_a_affec  --encaissement créé => RAF pour le gestionnaire
      --,sum(mt_non_valide) mt_non_valide_av_exclu --ss encais créé avec les exclus
FROM (     
    SELECT 
       vf.numporte,
       VF.fichier,
       vf.numremise,
       trunc(vf.datefic) datefic,
       vp.numligne,
       to_number(VP.MONTANT_OPE)/100 montant_total 
        ,(select sum(montant) from compte_client where numencaismt =vp.numencaismt and codope=8) montant_a_affec
        ,(select sum(montant) from compte_client where numencaismt =vp.numencaismt and codope<>8) montant_affecte
        ,( SELECT sum(to_number(MONTANT_OPE))/100   FROM VIR_PORTE_EXCLU where numremise = vp.numremise and numligne = vp.numligne) mnt_excl
        ,CASE WHEN vp.numencaismt IS NULL THEN to_number(VP.MONTANT_OPE)/100 
                    ELSE 0 END mt_non_valide
      FROM  VIR_FICHIER VF     
      LEFT OUTER JOIN  VIR_PORTE VP   ON vf.id_cpt = vp.id_cpt
      WHERE vf.numremise = vp.numremise 
       --and  vp.numremise = 18114
       AND vp.numcpte IS NOT NULL       
     )
GROUP BY
  numremise, numporte, fichier, datefic, 0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_VIR_IMPORT FOR ARTHUS.V_VIR_IMPORT
