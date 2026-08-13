CREATE FORCE VIEW ARTHUS.V_AFFIL_QTTC_MLO AS
SELECT  
         aq.NUMQUIT                                                             --   N° quittance Arthus
       , af.NUMCLI                                                              --   Société
       , f_nom(af.numcli) NOM_CLI
       , adh.NUMGAR                                                              --   n° contrat
       , adh.code_pop
       , cntrt.REFCIE                                                              --   Référence       
      -- , q.DEBUT 
      -- , q.FIN
       , trunc(af.datefic,'Q') DATEFIC_Q
       , SUM(ind.mt_base) MT_BASE
       , F_FIND_STATUT_CNTRT(aq.NUMQUIT)              STATUT                    --   Statut
       , DECODE (f_datemis (4, aq.numquit, 1, 0),
                         'Non émis', DECODE (f_datemis (4, aq.numquit,1,99),
                         'Non annulé', f_datemis       (4, aq.numquit,1,0),
                                       f_datemis       (4, aq.numquit,1,99)
                                            ),
                                       f_datemis       (4, aq.numquit, 1, 0)
                )                                    ETAT_QUITTANCE            --   Etat échéance calculée
      -- , q.montant_d                                 MT_ARTHUS                 --   Mt Arthus
      -- , (F_TOTQTTC_IND(aq.NUMQUIT)-q.montant_d  )    ECART                     --   Ecart Arthus DSN
     , af.numporte
    FROM AFFIL_PORTE_CNTRT ac, AFFIL_FICHIER af, AFFIL_PORTE ap,AFFIL_PORTE_ADH adh, contrat cntrt,AFFIL_PORTE_QTTC_INDIV ind, AFFIL_PORTE_QTTC aq 
--    left outer join V_QTTC_GLOBAL q   on q.NUMQUIT = aq.NUMQUIT
    --, V_QTTC_GLOBAL q  
    WHERE ac.numremise = af.numremise
    AND ac.numporte = af.numporte
    AND ac.ENTREPRISE = af.ENTREPRISE
    AND ac.etabli = af.etabli
    AND ac.num_ordre = af.num_ordre   
    AND ac.numremise = ap.numremise
    AND ac.numporte = ap.numporte
    AND ac.ENTREPRISE = ap.ENTREPRISE
    AND ac.etabli = ap.etabli
    AND ac.num_ordre = ap.num_ordre    
    AND adh.numremise = ac.numremise
    AND ac.numremise = aq.numremise
    AND adh.REF_EXT_CNTRT = ac.REF_EXT_CNTRT
    AND adh.REF_EXT_CNTRT = aq.REF_EXT_CNTRT
    AND adh.REF_EXT_ADH = aq.REF_EXT_ADH
    AND adh.numligne = aq.numligne
    AND adh.numligne = ap.numligne
    AND adh.numgar is not null
    AND adh.numgar = cntrt.numgar
    AND   aq.num_qttc = ind.num_qttc
    AND   aq.numligne = ind.numligne
    AND   aq.numporte = ind.numporte
    AND   aq.numremise = ind.numremise
  --  AND q.NUMQUIT(+) = aq.NUMQUIT
   /* AND ((aq.NUMQUIT IS NULL AND NOT EXISTS ( 
        SELECT  1 FROM AFFIL_PORTE_QTTC apq 
        WHERE ac.numremise = apq.numremise AND ac.numporte = apq.numporte
        AND adh.REF_EXT_CNTRT = apq.REF_EXT_CNTRT
        AND apq.numquit IS NOT NULL) ) OR aq.NUMQUIT IS NOT NULL) -- pose problème si ref_ext_cntrt identique pour des collèges diff */
    group by aq.NUMQUIT,af.NUMCLI, adh.NUMGAR ,adh.code_pop, cntrt.REFCIE , -- q.DEBUT , q.FIN , 
             trunc(af.datefic,'Q') , 
             -- q.montant_d ,
             af.numporte
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AFFIL_QTTC_MLO FOR ARTHUS.V_AFFIL_QTTC_MLO
